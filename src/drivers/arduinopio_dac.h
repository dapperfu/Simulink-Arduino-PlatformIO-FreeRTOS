#ifndef ARDUINOPIO_DAC_H
#define ARDUINOPIO_DAC_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

void arduinopioDacSetup(uint8_t pin, uint8_t resolutionBits);
void arduinopioDacWrite(uint8_t pin, uint16_t code);

#ifdef __cplusplus
}
#endif

#endif
