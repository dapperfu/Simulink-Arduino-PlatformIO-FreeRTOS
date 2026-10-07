#include "arduinopio_native_can.h"

#include <Arduino.h>

#if defined(ARDUINO_ARCH_SAM) && !defined(ARDUINO_ARCH_SAMD)
#include <due_can.h>
#define ARDUINOPIO_NATIVE_CAN_DUE 1
#elif defined(ARDUINO_UNOR4_MINIMA) || defined(ARDUINO_UNOR4_WIFI)
#include <Arduino_CAN.h>
#define ARDUINOPIO_NATIVE_CAN_R4 1
#endif

#if defined(ARDUINOPIO_NATIVE_CAN_DUE)
static CANRaw *dueBus(uint8_t controller)
{
    if (controller == 0) {
        return &Can0;
    }
    return &Can1;
}

static uint32_t dueBaud(uint16_t baudKbps)
{
    switch (baudKbps) {
    case 125:
        return 125000UL;
    case 250:
        return 250000UL;
    case 1000:
        return 1000000UL;
    default:
        return 500000UL;
    }
}
#endif

#if defined(ARDUINOPIO_NATIVE_CAN_R4)
static CanBitRate r4Baud(uint16_t baudKbps)
{
    switch (baudKbps) {
    case 125:
        return CanBitRate::BR_125k;
    case 250:
        return CanBitRate::BR_250k;
    case 1000:
        return CanBitRate::BR_1000k;
    default:
        return CanBitRate::BR_500k;
    }
}
#endif

extern "C" {

void arduinopioNativeCanSetup(uint8_t controller, uint16_t baudKbps)
{
#if defined(ARDUINOPIO_NATIVE_CAN_DUE)
    dueBus(controller)->begin(dueBaud(baudKbps));
#elif defined(ARDUINOPIO_NATIVE_CAN_R4)
    (void)controller;
    CAN.begin(r4Baud(baudKbps));
#else
    (void)controller;
    (void)baudKbps;
#endif
}

void arduinopioNativeCanSend(uint8_t controller, uint32_t identifier, uint8_t extended,
    uint8_t remote, const uint8_t *data, uint8_t length)
{
    uint8_t count = length > 8U ? 8U : length;

#if defined(ARDUINOPIO_NATIVE_CAN_DUE)
    CAN_FRAME frame = {};
    frame.id = identifier;
    frame.extended = extended;
    frame.rtr = remote;
    frame.length = (remote != 0U) ? 0U : count;
    for (uint8_t index = 0; index < frame.length; index++) {
        frame.data[index] = data[index];
    }
    dueBus(controller)->sendFrame(frame);
#elif defined(ARDUINOPIO_NATIVE_CAN_R4)
    (void)controller;
    (void)remote;
    uint8_t payload[8] = {};
    uint8_t sendCount = (remote != 0U) ? 0U : count;
    for (uint8_t index = 0; index < sendCount; index++) {
        payload[index] = data[index];
    }
    if (extended != 0U) {
        CanMsg message(CanExtendedId(identifier), sendCount, payload);
        CAN.write(message);
    } else {
        CanMsg message(CanStandardId(identifier), sendCount, payload);
        CAN.write(message);
    }
#else
    (void)controller;
    (void)identifier;
    (void)extended;
    (void)remote;
    (void)data;
    (void)count;
#endif
}

uint8_t arduinopioNativeCanReceive(uint8_t controller, uint32_t *identifier, uint8_t *extended,
    uint8_t *remote, uint8_t *data, uint8_t *length)
{
#if defined(ARDUINOPIO_NATIVE_CAN_DUE)
    CANRaw *bus = dueBus(controller);
    CAN_FRAME frame = {};
    if (bus->available() == 0 || bus->read(frame) == 0) {
        return 0;
    }
    *identifier = frame.id;
    *extended = frame.extended;
    *remote = frame.rtr;
    *length = frame.length > 8U ? 8U : frame.length;
    for (uint8_t index = 0; index < 8U; index++) {
        data[index] = (index < *length) ? frame.data[index] : 0U;
    }
    return 1;
#elif defined(ARDUINOPIO_NATIVE_CAN_R4)
    (void)controller;
    if (!CAN.available()) {
        return 0;
    }
    CanMsg message = CAN.read();
    bool isExtended = message.isExtendedId();
    *identifier = isExtended ? message.getExtendedId() : message.getStandardId();
    *extended = isExtended ? 1U : 0U;
    *remote = 0U;
    *length = message.data_length > 8U ? 8U : message.data_length;
    for (uint8_t index = 0; index < 8U; index++) {
        data[index] = (index < *length) ? message.data[index] : 0U;
    }
    return 1;
#else
    (void)controller;
    (void)identifier;
    (void)extended;
    (void)remote;
    (void)data;
    (void)length;
    return 0;
#endif
}

}
