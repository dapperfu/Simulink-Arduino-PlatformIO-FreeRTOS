#ifndef ARDUINOPIO_BLE_H
#define ARDUINOPIO_BLE_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

void arduinopioBleSetup(const char *deviceName, const char *serviceUuid, const char *characteristicUuid);
void arduinopioBleWrite(const uint8_t *data, uint8_t length);
uint8_t arduinopioBleRead(uint8_t *data, uint8_t length);

#ifdef __cplusplus
}
#endif

#endif
