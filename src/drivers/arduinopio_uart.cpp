#include "arduinopio_uart.h"

#include <Arduino.h>

static HardwareSerial *selectPort(uint8_t port)
{
    (void)port;
    return &Serial;
}

extern "C" {

void arduinopioUartSetup(uint8_t port, uint32_t baudRate)
{
    selectPort(port)->begin(baudRate);
}

void arduinopioUartWrite(uint8_t port, const uint8_t *data, uint8_t length)
{
    selectPort(port)->write(data, length);
}

uint8_t arduinopioUartRead(uint8_t port, uint8_t *data, uint8_t length)
{
    uint8_t count = 0;
    HardwareSerial *serialPort;

    serialPort = selectPort(port);
    while ((count < length) && (serialPort->available() > 0)) {
        data[count] = (uint8_t)serialPort->read();
        count++;
    }
    return count;
}

}
