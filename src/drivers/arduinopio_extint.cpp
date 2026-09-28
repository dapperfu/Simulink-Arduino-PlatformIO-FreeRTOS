#include "arduinopio_extint.h"

#include <Arduino.h>

#if __has_include(<Arduino_FreeRTOS.h>)
#include <Arduino_FreeRTOS.h>
#include <semphr.h>
#define ARDUINOPIO_HAS_FREERTOS 1
#else
#define ARDUINOPIO_HAS_FREERTOS 0
#endif

#ifndef ARDUINOPIO_MAX_EXTINT
#define ARDUINOPIO_MAX_EXTINT 2
#endif

static volatile uint8_t gExtIntCount[ARDUINOPIO_MAX_EXTINT];
static uint8_t gExtIntPins[ARDUINOPIO_MAX_EXTINT];
static uint8_t gExtIntUsed = 0;

#if ARDUINOPIO_HAS_FREERTOS
static SemaphoreHandle_t gExtIntSem[ARDUINOPIO_MAX_EXTINT];
#endif

static int8_t indexForPin(uint8_t pin)
{
    uint8_t i;

    for (i = 0; i < gExtIntUsed; ++i) {
        if (gExtIntPins[i] == pin) {
            return (int8_t)i;
        }
    }
    return -1;
}

static void extIntIsr0(void)
{
#if ARDUINOPIO_HAS_FREERTOS
    BaseType_t woken = pdFALSE;
    if (gExtIntSem[0] != NULL) {
        xSemaphoreGiveFromISR(gExtIntSem[0], &woken);
        portYIELD_FROM_ISR(woken);
        return;
    }
#endif
    gExtIntCount[0]++;
}

static void extIntIsr1(void)
{
#if ARDUINOPIO_HAS_FREERTOS
    BaseType_t woken = pdFALSE;
    if (gExtIntSem[1] != NULL) {
        xSemaphoreGiveFromISR(gExtIntSem[1], &woken);
        portYIELD_FROM_ISR(woken);
        return;
    }
#endif
    gExtIntCount[1]++;
}

static uint8_t toArduinoMode(uint8_t mode)
{
    switch (mode) {
    case 0:
        return LOW;
    case 1:
        return CHANGE;
    case 2:
        return FALLING;
    default:
        return RISING;
    }
}

extern "C" {

void arduinopioExtIntSetup(uint8_t pin, uint8_t mode, uint8_t pinPull)
{
    int8_t index;
    void (*isr)(void);

    if (pinPull == 1) {
        pinMode(pin, INPUT_PULLUP);
#ifdef INPUT_PULLDOWN
    } else if (pinPull == 2) {
        pinMode(pin, INPUT_PULLDOWN);
#endif
    } else {
        pinMode(pin, INPUT);
    }
    index = indexForPin(pin);
    if (index < 0) {
        if (gExtIntUsed >= ARDUINOPIO_MAX_EXTINT) {
            return;
        }
        index = (int8_t)gExtIntUsed;
        gExtIntPins[gExtIntUsed] = pin;
        gExtIntCount[gExtIntUsed] = 0;
#if ARDUINOPIO_HAS_FREERTOS
        gExtIntSem[gExtIntUsed] = xSemaphoreCreateCounting(16, 0);
#endif
        gExtIntUsed++;
    }

    isr = (index == 0) ? extIntIsr0 : extIntIsr1;
    attachInterrupt(digitalPinToInterrupt(pin), isr, toArduinoMode(mode));
}

uint8_t arduinopioExtIntTake(uint8_t pin)
{
    int8_t index = indexForPin(pin);
    uint8_t pending = 0;

    if (index < 0) {
        return 0;
    }
#if ARDUINOPIO_HAS_FREERTOS
    if ((gExtIntSem[index] != NULL) && (xTaskGetSchedulerState() == taskSCHEDULER_RUNNING)) {
        if (xSemaphoreTake(gExtIntSem[index], 0) == pdTRUE) {
            return 1;
        }
        return 0;
    }
#endif
    noInterrupts();
    if (gExtIntCount[index] > 0) {
        gExtIntCount[index]--;
        pending = 1;
    }
    interrupts();
    return pending;
}

}
