#include "arduinopio_spi.h"
#include "arduinopio_lock.h"

#include <Arduino.h>
#include <SPI.h>

static uint8_t toArduinoSpiMode(uint8_t spiMode)
{
    switch (spiMode) {
    case 1:
        return SPI_MODE1;
    case 2:
        return SPI_MODE2;
    case 3:
        return SPI_MODE3;
    default:
        return SPI_MODE0;
    }
}

extern "C" {

static uint32_t gSpiClockHz = 4000000UL;
static uint8_t gSpiMode = 0;
static uint8_t gSpiBitOrder = 1;

void arduinopioSpiSetup(uint8_t chipSelectPin, uint32_t clockHz, uint8_t spiMode, uint8_t bitOrder)
{
    gSpiClockHz = clockHz;
    gSpiMode = spiMode;
    gSpiBitOrder = bitOrder;

    arduinopioLock();
    pinMode(chipSelectPin, OUTPUT);
    digitalWrite(chipSelectPin, HIGH);
    SPI.begin();
    arduinopioUnlock();
}

void arduinopioSpiWriteRead(uint8_t chipSelectPin, const uint8_t *txData, uint8_t *rxData, uint8_t length)
{
    uint8_t i;
    BitOrder order = (gSpiBitOrder != 0) ? MSBFIRST : LSBFIRST;

    arduinopioLock();
    SPI.beginTransaction(SPISettings(gSpiClockHz, order, toArduinoSpiMode(gSpiMode)));
    digitalWrite(chipSelectPin, LOW);
    for (i = 0; i < length; ++i) {
        rxData[i] = SPI.transfer(txData[i]);
    }
    digitalWrite(chipSelectPin, HIGH);
    SPI.endTransaction();
    arduinopioUnlock();
}

}
