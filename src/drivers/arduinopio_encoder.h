#ifndef ARDUINOPIO_ENCODER_H
#define ARDUINOPIO_ENCODER_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

void arduinopioEncoderSetup(uint8_t pinA, uint8_t pinB);
int32_t arduinopioEncoderRead(uint8_t resetEachSample);
void arduinopioEncoderReset(void);

#ifdef __cplusplus
}
#endif

#endif
