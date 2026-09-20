#ifndef ARDUINOPIO_PWM_AVR_H
#define ARDUINOPIO_PWM_AVR_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

void arduinopioPwmAvrSetup(uint8_t pin, uint8_t timerId, uint8_t prescalerSelect, uint8_t fastPwm);
void arduinopioPwmAvrWrite(uint8_t pin, uint8_t duty);

#ifdef __cplusplus
}
#endif

#endif
