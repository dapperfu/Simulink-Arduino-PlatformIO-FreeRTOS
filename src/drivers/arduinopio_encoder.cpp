#include "arduinopio_encoder.h"

#include <Arduino.h>

static volatile int32_t gEncoderCount = 0;
static uint8_t gEncoderPinA = 2;
static uint8_t gEncoderPinB = 3;

static void encoderIsr(void)
{
    int8_t increment = 1;

    if (digitalRead(gEncoderPinA) == digitalRead(gEncoderPinB)) {
        increment = -1;
    }
    gEncoderCount += increment;
}

extern "C" {

void arduinopioEncoderSetup(uint8_t pinA, uint8_t pinB)
{
    gEncoderPinA = pinA;
    gEncoderPinB = pinB;
    gEncoderCount = 0;
    pinMode(pinA, INPUT_PULLUP);
    pinMode(pinB, INPUT_PULLUP);
    attachInterrupt(digitalPinToInterrupt(pinA), encoderIsr, CHANGE);
}

int32_t arduinopioEncoderRead(uint8_t resetEachSample)
{
    int32_t count;
    noInterrupts();
    count = gEncoderCount;
    if (resetEachSample != 0) {
        gEncoderCount = 0;
    }
    interrupts();
    return count;
}

void arduinopioEncoderReset(void)
{
    noInterrupts();
    gEncoderCount = 0;
    interrupts();
}

}
