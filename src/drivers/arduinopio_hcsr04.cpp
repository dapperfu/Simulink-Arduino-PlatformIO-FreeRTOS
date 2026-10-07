#include "arduinopio_hcsr04.h"

#include <Arduino.h>

extern "C" {

void arduinopioHcSr04Setup(uint8_t trigPin, uint8_t echoPin)
{
    pinMode(trigPin, OUTPUT);
    pinMode(echoPin, INPUT);
    digitalWrite(trigPin, LOW);
}

float arduinopioHcSr04ReadCm(uint8_t trigPin, uint8_t echoPin, uint32_t timeoutUs)
{
    digitalWrite(trigPin, LOW);
    delayMicroseconds(2);
    digitalWrite(trigPin, HIGH);
    delayMicroseconds(10);
    digitalWrite(trigPin, LOW);

    unsigned long durationUs = pulseIn(echoPin, HIGH, timeoutUs);
    if (durationUs == 0) {
        return 0.0f;
    }

    /* HC-SR04: centimeters ~= echo microseconds / 58. */
    return static_cast<float>(durationUs) / 58.0f;
}

}
