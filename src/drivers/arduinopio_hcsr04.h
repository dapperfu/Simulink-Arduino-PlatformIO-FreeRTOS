#ifndef ARDUINOPIO_HCSR04_H
#define ARDUINOPIO_HCSR04_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

void arduinopioHcSr04Setup(uint8_t trigPin, uint8_t echoPin);
float arduinopioHcSr04ReadCm(uint8_t trigPin, uint8_t echoPin, uint32_t timeoutUs);

#ifdef __cplusplus
}
#endif

#endif
