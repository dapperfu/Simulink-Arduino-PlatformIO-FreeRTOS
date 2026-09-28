#ifndef ARDUINOPIO_CAN_H
#define ARDUINOPIO_CAN_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

void arduinopioCanSetup(uint8_t chipSelectPin, uint16_t baudKbps, uint8_t oscillatorMHz, uint8_t mode);
void arduinopioCanSetFilter(uint8_t extended, uint32_t identifier, uint32_t mask);
uint8_t arduinopioCanSend(uint32_t identifier, uint8_t extended, uint8_t remote,
    const uint8_t *data, uint8_t length);
uint8_t arduinopioCanReceive(uint32_t *identifier, uint8_t *extended, uint8_t *remote,
    uint8_t *data, uint8_t *length);

#ifdef __cplusplus
}
#endif

#endif
