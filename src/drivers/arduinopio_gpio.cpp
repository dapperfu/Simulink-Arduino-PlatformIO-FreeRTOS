#include "arduinopio_gpio.h"
#include "arduinopio_lock.h"

#include <Arduino.h>

extern "C" {

void arduinopioDigitalOutputSetup(uint8_t pin)
{
    arduinopioLock();
    pinMode(pin, OUTPUT);
    arduinopioUnlock();
}

void arduinopioDigitalInputSetup(uint8_t pin, uint8_t pullup)
{
    arduinopioLock();
    pinMode(pin, pullup ? INPUT_PULLUP : INPUT);
    arduinopioUnlock();
}

void arduinopioDigitalWrite(uint8_t pin, uint8_t value)
{
    arduinopioLock();
    digitalWrite(pin, value ? HIGH : LOW);
    arduinopioUnlock();
}

uint8_t arduinopioDigitalRead(uint8_t pin)
{
    uint8_t value;

    arduinopioLock();
    value = digitalRead(pin) ? 1 : 0;
    arduinopioUnlock();
    return value;
}

}
