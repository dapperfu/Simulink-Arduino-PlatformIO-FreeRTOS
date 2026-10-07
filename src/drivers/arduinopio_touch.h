#ifndef ARDUINOPIO_TOUCH_H
#define ARDUINOPIO_TOUCH_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

void arduinopioTouchSetup(uint8_t pin);
uint16_t arduinopioTouchRead(uint8_t pin);

#ifdef __cplusplus
}
#endif

#endif
