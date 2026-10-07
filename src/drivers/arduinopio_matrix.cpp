#include "arduinopio_matrix.h"

#include <Arduino.h>

#if defined(ARDUINO_UNOR4_WIFI)
#include "Arduino_LED_Matrix.h"
static ArduinoLEDMatrix gMatrix;
static bool gMatrixReady = false;
#endif

extern "C" {

void arduinopioMatrixSetup(void)
{
#if defined(ARDUINO_UNOR4_WIFI)
    if (!gMatrixReady) {
        gMatrix.begin();
        gMatrixReady = true;
    }
#endif
}

void arduinopioMatrixWrite(const uint8_t *columns, uint8_t count)
{
#if defined(ARDUINO_UNOR4_WIFI)
    uint32_t frame[3] = {0, 0, 0};
    uint8_t columnCount = count > 12U ? 12U : count;
    uint8_t column;
    uint8_t row;

    if (!gMatrixReady) {
        arduinopioMatrixSetup();
    }

    for (row = 0; row < 8U; row++) {
        for (column = 0; column < columnCount; column++) {
            uint16_t bitIndex;
            if (((columns[column] >> row) & 0x1U) == 0U) {
                continue;
            }
            bitIndex = (uint16_t)row * 12U + column;
            frame[bitIndex / 32U] |= (1UL << (bitIndex % 32U));
        }
    }
    gMatrix.loadFrame(frame);
#else
    (void)columns;
    (void)count;
#endif
}

}
