#include "arduinopio_pwm.h"
#include "arduinopio_lock.h"

#include <Arduino.h>

extern "C" {

void arduinopioPwmSetup(uint8_t pin)
{
    arduinopioLock();
    pinMode(pin, OUTPUT);
    analogWrite(pin, 0);
    arduinopioUnlock();
}

void arduinopioPwmWrite(uint8_t pin, uint8_t duty)
{
    arduinopioLock();
    analogWrite(pin, duty);
    arduinopioUnlock();
}

}
