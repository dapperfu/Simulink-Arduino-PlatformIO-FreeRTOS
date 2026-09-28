#ifndef ARDUINOPIO_HWINT_AVR_H
#define ARDUINOPIO_HWINT_AVR_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

void arduinopioHwIntAvrSetup(uint8_t sourceId);
uint8_t arduinopioHwIntAvrTake(uint8_t sourceId);

#ifdef __cplusplus
}
#endif

#endif
