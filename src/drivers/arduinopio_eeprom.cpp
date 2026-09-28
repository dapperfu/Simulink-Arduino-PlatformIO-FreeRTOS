#include "arduinopio_eeprom.h"

#include <Arduino.h>
#include <EEPROM.h>

extern "C" {

void arduinopioEepromSetup(void)
{
}

void arduinopioEepromRead(uint16_t startAddress, uint8_t *data, uint8_t length)
{
    uint8_t i;

    for (i = 0; i < length; ++i) {
        data[i] = EEPROM.read(startAddress + i);
    }
}

void arduinopioEepromWrite(uint16_t startAddress, const uint8_t *data, uint8_t length)
{
    uint8_t i;

    for (i = 0; i < length; ++i) {
        EEPROM.update(startAddress + i, data[i]);
    }
}

}
