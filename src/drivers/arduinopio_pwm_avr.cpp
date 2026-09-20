#include "arduinopio_pwm_avr.h"
#include "arduinopio_lock.h"

#include <Arduino.h>

#if defined(__AVR_ATmega328P__) || defined(__AVR_ATmega328__)

static void configureTimer(uint8_t timerId, uint8_t prescalerSelect, uint8_t fastPwm)
{
    uint8_t csBits = prescalerSelect & 0x07;

    switch (timerId) {
    case 0:
        TCCR0A = fastPwm ? 0xA3 : 0xA1;
        TCCR0B = csBits;
        break;
    case 1:
        TCCR1A = fastPwm ? 0xA1 : 0xA0;
        TCCR1B = (uint8_t)((fastPwm ? (1 << WGM12) : 0) | csBits);
        break;
    case 2:
        TCCR2A = fastPwm ? 0xA3 : 0xA1;
        TCCR2B = csBits;
        break;
    default:
        break;
    }
}

#endif

extern "C" {

void arduinopioPwmAvrSetup(uint8_t pin, uint8_t timerId, uint8_t prescalerSelect, uint8_t fastPwm)
{
    arduinopioLock();
    pinMode(pin, OUTPUT);
#if defined(__AVR_ATmega328P__) || defined(__AVR_ATmega328__)
    configureTimer(timerId, prescalerSelect, fastPwm);
#else
    (void)timerId;
    (void)prescalerSelect;
    (void)fastPwm;
#endif
    analogWrite(pin, 0);
    arduinopioUnlock();
}

void arduinopioPwmAvrWrite(uint8_t pin, uint8_t duty)
{
    arduinopioLock();
    analogWrite(pin, duty);
    arduinopioUnlock();
}

}
