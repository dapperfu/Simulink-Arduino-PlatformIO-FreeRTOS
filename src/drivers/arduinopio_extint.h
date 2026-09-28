#ifndef ARDUINOPIO_EXTINT_H
#define ARDUINOPIO_EXTINT_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

void arduinopioExtIntSetup(uint8_t pin, uint8_t mode, uint8_t pinPull);
uint8_t arduinopioExtIntTake(uint8_t pin);

#ifdef __cplusplus
}
#endif

#endif
