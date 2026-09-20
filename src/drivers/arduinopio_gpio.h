#ifndef ARDUINOPIO_GPIO_H
#define ARDUINOPIO_GPIO_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

void arduinopioDigitalOutputSetup(uint8_t pin);
void arduinopioDigitalInputSetup(uint8_t pin, uint8_t pullup);
void arduinopioDigitalWrite(uint8_t pin, uint8_t value);
uint8_t arduinopioDigitalRead(uint8_t pin);

#ifdef __cplusplus
}
#endif

#endif
