#ifndef ARDUINOPIO_SPI_H
#define ARDUINOPIO_SPI_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

void arduinopioSpiSetup(uint8_t chipSelectPin, uint32_t clockHz, uint8_t spiMode, uint8_t bitOrder);
void arduinopioSpiWriteRead(uint8_t chipSelectPin, const uint8_t *txData, uint8_t *rxData, uint8_t length);

#ifdef __cplusplus
}
#endif

#endif
