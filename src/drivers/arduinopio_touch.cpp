#include "arduinopio_touch.h"

#include <Arduino.h>

extern "C" {

void arduinopioTouchSetup(uint8_t pin)
{
    (void)pin;
}

uint16_t arduinopioTouchRead(uint8_t pin)
{
#if defined(ARDUINO_ARCH_ESP32)
    return (uint16_t)touchRead(pin);
#else
    (void)pin;
    return 0;
#endif
}

}
