#include "arduinopio_lock.h"

#include <Arduino.h>

#if __has_include(<Arduino_FreeRTOS.h>)
#include <Arduino_FreeRTOS.h>
#include <semphr.h>
#define ARDUINOPIO_HAS_FREERTOS 1
#else
#define ARDUINOPIO_HAS_FREERTOS 0
#endif

#if ARDUINOPIO_HAS_FREERTOS
static SemaphoreHandle_t gDriverMutex = NULL;
#endif

extern "C" {

void arduinopioLockInit(void)
{
#if ARDUINOPIO_HAS_FREERTOS
    if (gDriverMutex == NULL) {
        gDriverMutex = xSemaphoreCreateMutex();
    }
#endif
}

void arduinopioLock(void)
{
#if ARDUINOPIO_HAS_FREERTOS
    arduinopioLockInit();
    if ((gDriverMutex != NULL) && (xTaskGetSchedulerState() == taskSCHEDULER_RUNNING)) {
        xSemaphoreTake(gDriverMutex, portMAX_DELAY);
    }
#endif
}

void arduinopioUnlock(void)
{
#if ARDUINOPIO_HAS_FREERTOS
    if ((gDriverMutex != NULL) && (xTaskGetSchedulerState() == taskSCHEDULER_RUNNING)) {
        xSemaphoreGive(gDriverMutex);
    }
#endif
}

}
