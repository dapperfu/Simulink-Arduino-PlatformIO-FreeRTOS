#include "arduinopio_uart.h"

#include <Arduino.h>

static HardwareSerial *selectPort(uint8_t port)
{
#if defined(ARDUINO_AVR_MEGA2560) || defined(__AVR_ATmega2560__) || defined(ARDUINO_ARCH_SAM)
    switch (port) {
    case 1:
        return &Serial1;
    case 2:
        return &Serial2;
    case 3:
        return &Serial3;
    default:
        return &Serial;
    }
#elif defined(ARDUINO_ARCH_ESP32)
    switch (port) {
    case 1:
        return &Serial1;
    case 2:
        return &Serial2;
    default:
        return &Serial;
    }
#elif defined(HAVE_HWSERIAL1)
    if (port == 1) {
        return &Serial1;
    }
    return &Serial;
#else
    (void)port;
    return &Serial;
#endif
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
