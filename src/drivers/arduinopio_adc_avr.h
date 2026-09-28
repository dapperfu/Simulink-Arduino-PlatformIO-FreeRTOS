#ifndef ARDUINOPIO_ADC_AVR_H
#define ARDUINOPIO_ADC_AVR_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

void arduinopioAdcAvrSetup(uint8_t pin, uint8_t referenceSelect, uint8_t prescalerSelect);
uint16_t arduinopioAdcAvrRead(uint8_t pin);

#ifdef __cplusplus
}
#endif

#endif
