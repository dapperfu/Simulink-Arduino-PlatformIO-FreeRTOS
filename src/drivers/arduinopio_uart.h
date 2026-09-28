#ifndef ARDUINOPIO_UART_H
#define ARDUINOPIO_UART_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

void arduinopioUartSetup(uint8_t port, uint32_t baudRate);
void arduinopioUartWrite(uint8_t port, const uint8_t *data, uint8_t length);
uint8_t arduinopioUartRead(uint8_t port, uint8_t *data, uint8_t length);

#ifdef __cplusplus
}
#endif

#endif
