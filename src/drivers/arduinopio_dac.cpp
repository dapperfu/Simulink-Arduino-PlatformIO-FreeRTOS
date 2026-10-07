#include "arduinopio_dac.h"

#include <Arduino.h>

extern "C" {

void arduinopioDacSetup(uint8_t pin, uint8_t resolutionBits)
{
#if defined(ARDUINO_ARCH_ESP32)
    (void)resolutionBits;
    pinMode(pin, OUTPUT);
#elif defined(ARDUINO_ARCH_AVR)
    (void)resolutionBits;
    pinMode(pin, OUTPUT);
#else
    analogWriteResolution(resolutionBits);
    pinMode(pin, OUTPUT);
#endif
}

void arduinopioDacWrite(uint8_t pin, uint16_t code)
{
#if defined(ARDUINO_ARCH_ESP32)
    dacWrite(pin, (uint8_t)code);
#elif defined(ARDUINO_ARCH_AVR)
    analogWrite(pin, (int)(code > 255U ? 255U : code));
#else
    analogWrite(pin, (int)code);
#endif
}

}
