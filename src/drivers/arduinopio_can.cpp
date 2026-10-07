#include "arduinopio_can.h"

#include <Arduino.h>
#include <mcp2515.h>
#include <new>

#if __has_include(<Arduino_FreeRTOS.h>)
#include <Arduino_FreeRTOS.h>
#include <queue.h>
#include <semphr.h>
#include <task.h>
#elif defined(ARDUINO_ARCH_ESP32)
#include "freertos/FreeRTOS.h"
#include "freertos/queue.h"
#include "freertos/semphr.h"
#include "freertos/task.h"
#else
#include "FreeRTOS.h"
#include "queue.h"
#include "semphr.h"
#include "task.h"
#endif

#ifndef ARDUINOPIO_CAN_RX_STACK
#define ARDUINOPIO_CAN_RX_STACK 192
#endif

#ifndef ARDUINOPIO_CAN_RX_PRIORITY
#define ARDUINOPIO_CAN_RX_PRIORITY (tskIDLE_PRIORITY + 3)
#endif

#ifndef ARDUINOPIO_CAN_RX_PERIOD_MS
#define ARDUINOPIO_CAN_RX_PERIOD_MS 1
#endif

#ifndef ARDUINOPIO_CAN_RX_QUEUE_LEN
#define ARDUINOPIO_CAN_RX_QUEUE_LEN 16
#endif

#ifndef ARDUINOPIO_CAN_RECV_TIMEOUT_MS
#define ARDUINOPIO_CAN_RECV_TIMEOUT_MS 10
#endif

#ifndef ARDUINOPIO_CAN_MUTEX_TIMEOUT_MS
#define ARDUINOPIO_CAN_MUTEX_TIMEOUT_MS 50
#endif

static const uint32_t kSpiClockHz = 8000000UL;
static const uint8_t kMaxDlc = 8;
static const uint8_t kLoopbackMode = 1;
static const uint8_t kListenOnlyMode = 2;

struct CanQueuedFrame {
    uint32_t identifier;
    uint8_t extended;
    uint8_t remote;
    uint8_t length;
    uint8_t data[8];
};

static MCP2515 *gCan = nullptr;
alignas(MCP2515) static uint8_t gCanMemory[sizeof(MCP2515)];
static uint8_t gCanMode = 0;
static uint16_t gReceiveTimeoutMs = ARDUINOPIO_CAN_RECV_TIMEOUT_MS;
static SemaphoreHandle_t gCanMutex = NULL;
static QueueHandle_t gRxQueue = NULL;
static TaskHandle_t gRxTask = NULL;
static uint8_t gStarted = 0;

static CAN_SPEED toCanSpeed(uint16_t baudKbps)
{
    switch (baudKbps) {
    case 125:
        return CAN_125KBPS;
    case 250:
        return CAN_250KBPS;
    case 1000:
        return CAN_1000KBPS;
    default:
        return CAN_500KBPS;
    }
}

static CAN_CLOCK toCanClock(uint8_t oscillatorMHz)
{
    switch (oscillatorMHz) {
    case 16:
        return MCP_16MHZ;
    case 20:
        return MCP_20MHZ;
    default:
        return MCP_8MHZ;
    }
}

static void applyOperatingMode(uint8_t mode)
{
    switch (mode) {
    case kLoopbackMode:
        gCan->setLoopbackMode();
        break;
    case kListenOnlyMode:
        gCan->setListenOnlyMode();
        break;
    default:
        gCan->setNormalMode();
        break;
    }
}

static bool lockCan(void)
{
    if (gCanMutex == NULL) {
        return true;
    }
    if (xTaskGetSchedulerState() != taskSCHEDULER_RUNNING) {
        return (xSemaphoreTake(gCanMutex, 0) == pdTRUE);
    }
    return (xSemaphoreTake(gCanMutex, pdMS_TO_TICKS(ARDUINOPIO_CAN_MUTEX_TIMEOUT_MS)) == pdTRUE);
}

static void unlockCan(void)
{
    if (gCanMutex != NULL) {
        xSemaphoreGive(gCanMutex);
    }
}

static void frameFromMcp(const struct can_frame *frame, CanQueuedFrame *out)
{
    uint8_t i;

    out->extended = ((frame->can_id & CAN_EFF_FLAG) != 0) ? 1 : 0;
    out->remote = ((frame->can_id & CAN_RTR_FLAG) != 0) ? 1 : 0;
    if (out->extended != 0) {
        out->identifier = frame->can_id & CAN_EFF_MASK;
    } else {
        out->identifier = frame->can_id & CAN_SFF_MASK;
    }

    out->length = frame->can_dlc;
    if (out->length > kMaxDlc) {
        out->length = kMaxDlc;
    }
    for (i = 0; i < kMaxDlc; ++i) {
        out->data[i] = 0;
    }
    for (i = 0; i < out->length; ++i) {
        out->data[i] = frame->data[i];
    }
}

static void enqueueFrame(const CanQueuedFrame *frame)
{
    CanQueuedFrame discarded;

    if (gRxQueue == NULL) {
        return;
    }

    if (xQueueSend(gRxQueue, frame, 0) == pdTRUE) {
        return;
    }

    /* Queue full: drop oldest so the newest traffic is retained. */
    (void)xQueueReceive(gRxQueue, &discarded, 0);
    (void)xQueueSend(gRxQueue, frame, 0);
}

static void drainMcpReceiveBuffers(void)
{
    struct can_frame frame;
    CanQueuedFrame queued;
    uint8_t drained = 0;

    if ((gCan == nullptr) || !lockCan()) {
        return;
    }

    while ((drained < ARDUINOPIO_CAN_RX_QUEUE_LEN) &&
           (gCan->readMessage(&frame) == MCP2515::ERROR_OK)) {
        frameFromMcp(&frame, &queued);
        unlockCan();
        enqueueFrame(&queued);
        drained++;
        if (!lockCan()) {
            return;
        }
    }

    unlockCan();
}

static void canRxTask(void *taskParameter)
{
    const TickType_t periodTicks = pdMS_TO_TICKS(ARDUINOPIO_CAN_RX_PERIOD_MS);
    TickType_t lastWakeTick = xTaskGetTickCount();

    (void)taskParameter;

    for (;;) {
        drainMcpReceiveBuffers();
        vTaskDelayUntil(&lastWakeTick, periodTicks);
    }
}

static void ensureSyncPrimitives(void)
{
    if (gCanMutex == NULL) {
        gCanMutex = xSemaphoreCreateMutex();
    }
    if (gRxQueue == NULL) {
        gRxQueue = xQueueCreate(ARDUINOPIO_CAN_RX_QUEUE_LEN, sizeof(CanQueuedFrame));
    }
}

extern "C" {

void arduinopioCanSetup(uint8_t chipSelectPin, uint16_t baudKbps, uint8_t oscillatorMHz, uint8_t mode)
{
    ensureSyncPrimitives();

    if (!lockCan()) {
        return;
    }

    if (gCan == nullptr) {
        gCan = new (gCanMemory) MCP2515(chipSelectPin, kSpiClockHz);
        gCan->reset();
        gCan->setBitrate(toCanSpeed(baudKbps), toCanClock(oscillatorMHz));
        gCanMode = mode;
        applyOperatingMode(mode);
    }

    unlockCan();

    if ((gStarted == 0) && (gRxQueue != NULL) && (gRxTask == NULL)) {
        if (xTaskCreate(canRxTask, "canRx", ARDUINOPIO_CAN_RX_STACK, NULL,
                        ARDUINOPIO_CAN_RX_PRIORITY, &gRxTask) == pdPASS) {
            gStarted = 1;
        }
    }
}

void arduinopioCanSetReceiveTimeout(uint16_t timeoutMs)
{
    gReceiveTimeoutMs = timeoutMs;
}

void arduinopioCanSetFilter(uint8_t extended, uint32_t identifier, uint32_t mask)
{
    bool useExtended = (extended != 0);

    if ((gCan == nullptr) || !lockCan()) {
        return;
    }

    gCan->setFilterMask(MCP2515::MASK0, useExtended, mask);
    gCan->setFilterMask(MCP2515::MASK1, useExtended, mask);
    gCan->setFilter(MCP2515::RXF0, useExtended, identifier);
    gCan->setFilter(MCP2515::RXF1, useExtended, identifier);
    gCan->setFilter(MCP2515::RXF2, useExtended, identifier);
    gCan->setFilter(MCP2515::RXF3, useExtended, identifier);
    gCan->setFilter(MCP2515::RXF4, useExtended, identifier);
    gCan->setFilter(MCP2515::RXF5, useExtended, identifier);
    applyOperatingMode(gCanMode);
    unlockCan();
}

uint8_t arduinopioCanSend(uint32_t identifier, uint8_t extended, uint8_t remote,
    const uint8_t *data, uint8_t length)
{
    struct can_frame frame;
    uint8_t i;
    MCP2515::ERROR status;

    if ((gCan == nullptr) || (data == nullptr)) {
        return 0;
    }
    if (length > kMaxDlc) {
        length = kMaxDlc;
    }

    if (extended != 0) {
        frame.can_id = (identifier & CAN_EFF_MASK) | CAN_EFF_FLAG;
    } else {
        frame.can_id = identifier & CAN_SFF_MASK;
    }
    if (remote != 0) {
        frame.can_id |= CAN_RTR_FLAG;
    }

    frame.can_dlc = length;
    for (i = 0; i < length; ++i) {
        frame.data[i] = data[i];
    }

    if (!lockCan()) {
        return 0;
    }
    status = gCan->sendMessage(&frame);
    unlockCan();
    return (status == MCP2515::ERROR_OK) ? 1 : 0;
}

uint8_t arduinopioCanReceive(uint32_t *identifier, uint8_t *extended, uint8_t *remote,
    uint8_t *data, uint8_t *length)
{
    CanQueuedFrame queued;
    uint8_t i;
    TickType_t waitTicks;
    BaseType_t gotFrame;

    if ((identifier == nullptr) || (extended == nullptr) || (remote == nullptr) ||
        (data == nullptr) || (length == nullptr)) {
        return 0;
    }

    *identifier = 0;
    *extended = 0;
    *remote = 0;
    *length = 0;
    for (i = 0; i < kMaxDlc; ++i) {
        data[i] = 0;
    }

    if (gRxQueue == NULL) {
        ensureSyncPrimitives();
        if (gRxQueue == NULL) {
            return 0;
        }
    }

    if ((gReceiveTimeoutMs == 0) || (xTaskGetSchedulerState() != taskSCHEDULER_RUNNING)) {
        waitTicks = 0;
    } else {
        waitTicks = pdMS_TO_TICKS(gReceiveTimeoutMs);
    }

    gotFrame = xQueueReceive(gRxQueue, &queued, waitTicks);
    if (gotFrame != pdTRUE) {
        /* One opportunistic drain helps when the RX task has not run yet. */
        drainMcpReceiveBuffers();
        gotFrame = xQueueReceive(gRxQueue, &queued, 0);
        if (gotFrame != pdTRUE) {
            return 0;
        }
    }

    *identifier = queued.identifier;
    *extended = queued.extended;
    *remote = queued.remote;
    *length = queued.length;
    for (i = 0; i < queued.length; ++i) {
        data[i] = queued.data[i];
    }
    return 1;
}

}
