#include "arduinopio_adc.h"
#include "arduinopio_lock.h"

#include <Arduino.h>

extern "C" {

void arduinopioAnalogSetup(uint8_t pin)
{
    (void)pin;
    arduinopioLock();
    analogReference(DEFAULT);
    arduinopioUnlock();
}

uint16_t arduinopioAnalogRead(uint8_t pin)
{
    uint16_t value;

    arduinopioLock();
    value = (uint16_t)analogRead(pin);
    arduinopioUnlock();
    return value;
}

void arduinopioAnalogWriteSetup(uint8_t pin)
{
    arduinopioLock();
    pinMode(pin, OUTPUT);
    analogWrite(pin, 0);
    arduinopioUnlock();
}

void arduinopioAnalogWrite(uint8_t pin, uint8_t value)
{
    arduinopioLock();
    analogWrite(pin, value);
    arduinopioUnlock();
}

}
