#ifndef ARDUINOPIO_MATRIX_H
#define ARDUINOPIO_MATRIX_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

void arduinopioMatrixSetup(void);
void arduinopioMatrixWrite(const uint8_t *columns, uint8_t count);

#ifdef __cplusplus
}
#endif

#endif
