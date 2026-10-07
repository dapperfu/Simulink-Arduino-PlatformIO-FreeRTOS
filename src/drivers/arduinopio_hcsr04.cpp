#include "arduinopio_hcsr04.h"

#include <Arduino.h>

#if __has_include(<Arduino_FreeRTOS.h>)
#include <Arduino_FreeRTOS.h>
#include <semphr.h>
#include <task.h>
#elif defined(ARDUINO_ARCH_ESP32)
#include "freertos/FreeRTOS.h"
#include "freertos/semphr.h"
#include "freertos/task.h"
#else
#include "FreeRTOS.h"
#include "semphr.h"
#include "task.h"
#endif

#ifndef ARDUINOPIO_HCSR04_STACK
#define ARDUINOPIO_HCSR04_STACK 160
#endif

#ifndef ARDUINOPIO_HCSR04_PRIORITY
#define ARDUINOPIO_HCSR04_PRIORITY (tskIDLE_PRIORITY + 2)
#endif

static uint8_t gTrigPin = 9;
static uint8_t gEchoPin = 2;
static uint16_t gPeriodMs = 10;
static uint16_t gMaxDistanceCm = 400;
static volatile float gDistanceCm = 0.0f;
static volatile uint32_t gEchoRiseUs = 0;
static volatile uint8_t gEchoHigh = 0;
static uint8_t gUseInterrupt = 0;
static SemaphoreHandle_t gEchoDone = NULL;
static TaskHandle_t gTask = NULL;
static uint8_t gStarted = 0;

static uint32_t echoTimeoutUs(void)
{
    return (static_cast<uint32_t>(gMaxDistanceCm) * 58U) + 1000U;
}

/* HC-SR04 needs a >=10 us Trig high. FreeRTOS ticks are ms-scale, so this
 * short wait uses micros() in the sensor task — never delayMicroseconds. */
static void triggerBurst(uint8_t trigPin)
{
    uint32_t startUs;

    digitalWrite(trigPin, LOW);
    startUs = micros();
    while ((uint32_t)(micros() - startUs) < 2U) {
    }

    digitalWrite(trigPin, HIGH);
    startUs = micros();
    while ((uint32_t)(micros() - startUs) < 10U) {
    }
    digitalWrite(trigPin, LOW);
}

static void echoIsr(void)
{
    BaseType_t woken = pdFALSE;
    const uint32_t nowUs = micros();

    if (digitalRead(gEchoPin) != 0) {
        gEchoRiseUs = nowUs;
        gEchoHigh = 1;
        return;
    }

    if (gEchoHigh == 0) {
        return;
    }
    gEchoHigh = 0;

    {
        const uint32_t durationUs = nowUs - gEchoRiseUs;
        if (durationUs > 0U) {
            gDistanceCm = static_cast<float>(durationUs) / 58.0f;
        } else {
            gDistanceCm = 0.0f;
        }
    }

    if (gEchoDone != NULL) {
        xSemaphoreGiveFromISR(gEchoDone, &woken);
        portYIELD_FROM_ISR(woken);
    }
}

static void measureByPolling(void)
{
    const uint32_t timeoutUs = echoTimeoutUs();
    uint32_t startUs;
    uint32_t riseUs;

    startUs = micros();
    while (digitalRead(gEchoPin) == 0) {
        if ((uint32_t)(micros() - startUs) > timeoutUs) {
            gDistanceCm = 0.0f;
            return;
        }
    }

    riseUs = micros();
    while (digitalRead(gEchoPin) != 0) {
        if ((uint32_t)(micros() - riseUs) > timeoutUs) {
            gDistanceCm = 0.0f;
            return;
        }
    }

    {
        const uint32_t durationUs = micros() - riseUs;
        gDistanceCm = (durationUs > 0U) ? (static_cast<float>(durationUs) / 58.0f) : 0.0f;
    }
}

static void measureOnce(void)
{
    const uint32_t timeoutMs = (echoTimeoutUs() / 1000U) + 1U;
    const TickType_t echoTimeoutTicks = pdMS_TO_TICKS(timeoutMs);

    if (gUseInterrupt != 0) {
        if (gEchoDone != NULL) {
            while (xSemaphoreTake(gEchoDone, 0) == pdTRUE) {
            }
        }
        gEchoHigh = 0;
        triggerBurst(gTrigPin);

        if ((gEchoDone == NULL) ||
            (xSemaphoreTake(gEchoDone, echoTimeoutTicks) != pdTRUE)) {
            gDistanceCm = 0.0f;
            gEchoHigh = 0;
        }
        return;
    }

    triggerBurst(gTrigPin);
    measureByPolling();
}

static void hcsr04Task(void *taskParameter)
{
    const TickType_t periodTicks = pdMS_TO_TICKS(gPeriodMs);
    TickType_t lastWakeTick = xTaskGetTickCount();

    (void)taskParameter;

    for (;;) {
        measureOnce();
        vTaskDelayUntil(&lastWakeTick, periodTicks);
    }
}

extern "C" {

void arduinopioHcSr04Setup(uint8_t trigPin, uint8_t echoPin, uint16_t periodMs,
                           uint16_t maxDistanceCm)
{
    if (gStarted != 0) {
        return;
    }

    gTrigPin = trigPin;
    gEchoPin = echoPin;
    gPeriodMs = (periodMs == 0) ? 10U : periodMs;
    gMaxDistanceCm = (maxDistanceCm == 0) ? 400U : maxDistanceCm;
    gDistanceCm = 0.0f;
    gEchoHigh = 0;

    pinMode(gTrigPin, OUTPUT);
    pinMode(gEchoPin, INPUT);
    digitalWrite(gTrigPin, LOW);

    gUseInterrupt = 0;
#if defined(NOT_AN_INTERRUPT)
    if (digitalPinToInterrupt(gEchoPin) != NOT_AN_INTERRUPT) {
#else
    if (digitalPinToInterrupt(gEchoPin) >= 0) {
#endif
        if (gEchoDone == NULL) {
            gEchoDone = xSemaphoreCreateBinary();
        }
        if (gEchoDone != NULL) {
            attachInterrupt(digitalPinToInterrupt(gEchoPin), echoIsr, CHANGE);
            gUseInterrupt = 1;
        }
    }

    if (xTaskCreate(hcsr04Task, "hcsr04", ARDUINOPIO_HCSR04_STACK, NULL,
                    ARDUINOPIO_HCSR04_PRIORITY, &gTask) == pdPASS) {
        gStarted = 1;
    }
}

float arduinopioHcSr04ReadCm(void)
{
    float distanceCm;

    taskENTER_CRITICAL();
    distanceCm = gDistanceCm;
    taskEXIT_CRITICAL();
    return distanceCm;
}

}
