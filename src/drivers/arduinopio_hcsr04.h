#ifndef ARDUINOPIO_HCSR04_H
#define ARDUINOPIO_HCSR04_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/* Start a FreeRTOS task that owns Trig/Echo. periodMs is the task period. */
void arduinopioHcSr04Setup(uint8_t trigPin, uint8_t echoPin, uint16_t periodMs,
                           uint16_t maxDistanceCm);

/* Non-blocking snapshot of the latest distance in centimeters (0 if none yet). */
float arduinopioHcSr04ReadCm(void);

#ifdef __cplusplus
}
#endif

#endif
