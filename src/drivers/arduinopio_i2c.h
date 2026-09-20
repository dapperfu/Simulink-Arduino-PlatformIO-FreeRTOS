#ifndef ARDUINOPIO_I2C_H
#define ARDUINOPIO_I2C_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

void arduinopioI2cSetup(void);
void arduinopioI2cWrite(uint8_t address, uint8_t hasRegister, uint8_t registerAddress,
    const uint8_t *data, uint8_t length);
uint8_t arduinopioI2cRead(uint8_t address, uint8_t hasRegister, uint8_t registerAddress,
    uint8_t *data, uint8_t length);

#ifdef __cplusplus
}
#endif

#endif
