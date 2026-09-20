#ifndef ARDUINOPIO_CAPTURE_H
#define ARDUINOPIO_CAPTURE_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

void arduinopioCaptureSetup(uint8_t pin);
void arduinopioCaptureRead(float *frequencyHz, float *dutyCycle);

#ifdef __cplusplus
}
#endif

#endif
