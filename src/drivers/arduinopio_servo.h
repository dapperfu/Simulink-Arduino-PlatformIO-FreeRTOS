#ifndef ARDUINOPIO_SERVO_H
#define ARDUINOPIO_SERVO_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

void arduinopioServoSetup(uint8_t pin);
void arduinopioServoWriteAngle(uint8_t pin, uint8_t angleDeg);
void arduinopioServoWriteSpeed(uint8_t pin, int8_t speed);
uint8_t arduinopioServoReadAngle(uint8_t pin);

#ifdef __cplusplus
}
#endif

#endif
