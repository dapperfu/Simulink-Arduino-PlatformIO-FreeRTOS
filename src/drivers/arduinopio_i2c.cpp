#include "arduinopio_i2c.h"

#include <Arduino.h>
#include <Wire.h>

extern "C" {

void arduinopioI2cSetup(void)
{
    Wire.begin();
}

void arduinopioI2cWrite(uint8_t address, uint8_t hasRegister, uint8_t registerAddress,
    const uint8_t *data, uint8_t length)
{
    uint8_t i;

    Wire.beginTransmission(address);
    if (hasRegister != 0) {
        Wire.write(registerAddress);
    }
    for (i = 0; i < length; ++i) {
        Wire.write(data[i]);
    }
    Wire.endTransmission();
}

uint8_t arduinopioI2cRead(uint8_t address, uint8_t hasRegister, uint8_t registerAddress,
    uint8_t *data, uint8_t length)
{
    uint8_t count = 0;
    uint8_t i;

    if (hasRegister != 0) {
        Wire.beginTransmission(address);
        Wire.write(registerAddress);
        Wire.endTransmission(false);
    }
    count = (uint8_t)Wire.requestFrom(address, length);
    for (i = 0; (i < count) && (i < length); ++i) {
        data[i] = (uint8_t)Wire.read();
    }
    return count;
}

}
