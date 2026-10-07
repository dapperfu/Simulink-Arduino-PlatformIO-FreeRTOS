#ifndef ARDUINOPIO_NATIVE_CAN_H
#define ARDUINOPIO_NATIVE_CAN_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

void arduinopioNativeCanSetup(uint8_t controller, uint16_t baudKbps);
void arduinopioNativeCanSend(uint8_t controller, uint32_t identifier, uint8_t extended,
    uint8_t remote, const uint8_t *data, uint8_t length);
uint8_t arduinopioNativeCanReceive(uint8_t controller, uint32_t *identifier, uint8_t *extended,
    uint8_t *remote, uint8_t *data, uint8_t *length);

#ifdef __cplusplus
}
#endif

#endif
