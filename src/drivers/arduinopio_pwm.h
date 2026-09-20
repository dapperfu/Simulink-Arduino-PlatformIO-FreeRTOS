#ifndef ARDUINOPIO_PWM_H
#define ARDUINOPIO_PWM_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

void arduinopioPwmSetup(uint8_t pin);
void arduinopioPwmWrite(uint8_t pin, uint8_t duty);

#ifdef __cplusplus
}
#endif

#endif
