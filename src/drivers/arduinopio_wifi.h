#ifndef ARDUINOPIO_WIFI_H
#define ARDUINOPIO_WIFI_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

void arduinopioWifiSetup(const char *ssid, const char *password);
void arduinopioWifiUdpSend(const char *host, uint16_t port, const uint8_t *data, uint8_t length);
uint8_t arduinopioWifiUdpReceive(uint16_t localPort, uint8_t *data, uint8_t length);
void arduinopioWifiTcpSend(const char *host, uint16_t port, const uint8_t *data, uint8_t length);
uint8_t arduinopioWifiTcpReceive(const char *host, uint16_t port, uint8_t *data, uint8_t length);

#ifdef __cplusplus
}
#endif

#endif
