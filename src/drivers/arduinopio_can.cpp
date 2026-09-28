#include "arduinopio_can.h"

#include <Arduino.h>
#include <mcp2515.h>
#include <new>

static const uint32_t kSpiClockHz = 8000000UL;
static const uint8_t kMaxDlc = 8;
static const uint8_t kLoopbackMode = 1;
static const uint8_t kListenOnlyMode = 2;

static MCP2515 *gCan = nullptr;
alignas(MCP2515) static uint8_t gCanMemory[sizeof(MCP2515)];
static uint8_t gCanMode = 0;

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

extern "C" {

void arduinopioCanSetup(uint8_t chipSelectPin, uint16_t baudKbps, uint8_t oscillatorMHz, uint8_t mode)
{
    if (gCan == nullptr) {
        gCan = new (gCanMemory) MCP2515(chipSelectPin, kSpiClockHz);
        gCan->reset();
        gCan->setBitrate(toCanSpeed(baudKbps), toCanClock(oscillatorMHz));
        gCanMode = mode;
        applyOperatingMode(mode);
    }
}

void arduinopioCanSetFilter(uint8_t extended, uint32_t identifier, uint32_t mask)
{
    bool useExtended = (extended != 0);

    if (gCan == nullptr) {
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

    status = gCan->sendMessage(&frame);
    return (status == MCP2515::ERROR_OK) ? 1 : 0;
}

uint8_t arduinopioCanReceive(uint32_t *identifier, uint8_t *extended, uint8_t *remote,
    uint8_t *data, uint8_t *length)
{
    struct can_frame frame;
    uint8_t i;
    MCP2515::ERROR status;

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

    if (gCan == nullptr) {
        return 0;
    }

    status = gCan->readMessage(&frame);
    if (status != MCP2515::ERROR_OK) {
        return 0;
    }

    *extended = ((frame.can_id & CAN_EFF_FLAG) != 0) ? 1 : 0;
    *remote = ((frame.can_id & CAN_RTR_FLAG) != 0) ? 1 : 0;
    if (*extended != 0) {
        *identifier = frame.can_id & CAN_EFF_MASK;
    } else {
        *identifier = frame.can_id & CAN_SFF_MASK;
    }

    *length = frame.can_dlc;
    if (*length > kMaxDlc) {
        *length = kMaxDlc;
    }
    for (i = 0; i < *length; ++i) {
        data[i] = frame.data[i];
    }
    return 1;
}

}
