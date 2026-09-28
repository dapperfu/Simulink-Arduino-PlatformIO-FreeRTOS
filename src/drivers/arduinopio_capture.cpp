#include "arduinopio_capture.h"

#include <Arduino.h>

#if defined(__AVR_ATmega328P__) || defined(__AVR_ATmega328__)

static volatile uint16_t gCapturePeriod = 0;
static volatile uint16_t gCaptureHigh = 0;
static volatile uint8_t gCaptureReady = 0;
static volatile uint8_t gCaptureRising = 1;
static volatile uint16_t gCaptureRiseStamp = 0;

ISR(TIMER1_CAPT_vect)
{
    uint16_t stamp = ICR1;

    if (gCaptureRising != 0) {
        if (gCaptureRiseStamp != 0) {
            gCapturePeriod = stamp - gCaptureRiseStamp;
            gCaptureReady = 1;
        }
        gCaptureRiseStamp = stamp;
        TCCR1B &= ~(1 << ICES1);
        gCaptureRising = 0;
    } else {
        gCaptureHigh = stamp - gCaptureRiseStamp;
        TCCR1B |= (1 << ICES1);
        gCaptureRising = 1;
    }
    TIFR1 |= (1 << ICF1);
}

#endif

extern "C" {

void arduinopioCaptureSetup(uint8_t pin)
{
    (void)pin;
#if defined(__AVR_ATmega328P__) || defined(__AVR_ATmega328__)
    pinMode(8, INPUT);
    TCCR1A = 0;
    TCCR1B = (1 << ICES1) | (1 << CS11);
    TIMSK1 |= (1 << ICIE1);
#endif
}

void arduinopioCaptureRead(float *frequencyHz, float *dutyCycle)
{
    uint16_t period;
    uint16_t highTime;

    *frequencyHz = 0.0f;
    *dutyCycle = 0.0f;
#if defined(__AVR_ATmega328P__) || defined(__AVR_ATmega328__)
    noInterrupts();
    period = gCapturePeriod;
    highTime = gCaptureHigh;
    interrupts();
    if ((period != 0) && (gCaptureReady != 0)) {
        /* Timer1 with prescaler 8 at 16 MHz: 0.5 us per tick. */
        *frequencyHz = 2000000.0f / (float)period;
        *dutyCycle = (100.0f * (float)highTime) / (float)period;
    }
#else
    (void)period;
    (void)highTime;
#endif
}

}
