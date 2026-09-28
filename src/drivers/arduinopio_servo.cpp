#include "arduinopio_servo.h"

#include <Arduino.h>
#include <Servo.h>

#ifndef ARDUINOPIO_MAX_SERVOS
#define ARDUINOPIO_MAX_SERVOS 8
#endif

static Servo gServos[ARDUINOPIO_MAX_SERVOS];
static uint8_t gServoPins[ARDUINOPIO_MAX_SERVOS];
static uint8_t gServoCount = 0;

static Servo *servoForPin(uint8_t pin)
{
    uint8_t i;

    for (i = 0; i < gServoCount; ++i) {
        if (gServoPins[i] == pin) {
            return &gServos[i];
        }
    }
    if (gServoCount >= ARDUINOPIO_MAX_SERVOS) {
        return NULL;
    }
    gServoPins[gServoCount] = pin;
    gServos[gServoCount].attach(pin);
    gServoCount++;
    return &gServos[gServoCount - 1];
}

extern "C" {

void arduinopioServoSetup(uint8_t pin)
{
    (void)servoForPin(pin);
}

void arduinopioServoWriteAngle(uint8_t pin, uint8_t angleDeg)
{
    Servo *servo;

    servo = servoForPin(pin);
    if (servo != NULL) {
        servo->write(angleDeg);
    }
}

void arduinopioServoWriteSpeed(uint8_t pin, int8_t speed)
{
    uint8_t angle;

    if (speed < -100) {
        speed = -100;
    }
    if (speed > 100) {
        speed = 100;
    }
    angle = (uint8_t)map(speed, -100, 100, 0, 180);
    arduinopioServoWriteAngle(pin, angle);
}

uint8_t arduinopioServoReadAngle(uint8_t pin)
{
    Servo *servo;
    uint8_t angle = 0;

    servo = servoForPin(pin);
    if (servo != NULL) {
        angle = (uint8_t)servo->read();
    }
    return angle;
}

}
