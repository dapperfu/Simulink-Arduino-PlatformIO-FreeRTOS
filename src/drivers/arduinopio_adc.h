#ifndef ARDUINOPIO_ADC_H
#define ARDUINOPIO_ADC_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

void arduinopioAnalogSetup(uint8_t pin);
uint16_t arduinopioAnalogRead(uint8_t pin);
void arduinopioAnalogWriteSetup(uint8_t pin);
void arduinopioAnalogWrite(uint8_t pin, uint8_t value);

#ifdef __cplusplus
}
#endif

#endif
