#ifndef ARDUINOPIO_EEPROM_H
#define ARDUINOPIO_EEPROM_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

void arduinopioEepromSetup(void);
void arduinopioEepromRead(uint16_t startAddress, uint8_t *data, uint8_t length);
void arduinopioEepromWrite(uint16_t startAddress, const uint8_t *data, uint8_t length);

#ifdef __cplusplus
}
#endif

#endif
