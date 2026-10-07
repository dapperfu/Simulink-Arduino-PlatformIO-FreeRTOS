#include "arduinopio_wifi.h"

#include <Arduino.h>

#if defined(ARDUINO_ARCH_ESP32)
#include <WiFi.h>
#include <WiFiUdp.h>
#define ARDUINOPIO_HAS_WIFI 1
#elif defined(ARDUINO_UNOR4_WIFI)
#include <WiFiS3.h>
#define ARDUINOPIO_HAS_WIFI 1
#elif defined(ARDUINO_ARCH_SAMD)
#include <WiFiNINA.h>
#define ARDUINOPIO_HAS_WIFI 1
#endif

#if defined(ARDUINOPIO_HAS_WIFI)
static WiFiUDP gUdp;
static WiFiClient gClient;
static bool gWifiReady = false;
static bool gUdpReady = false;
static uint16_t gUdpPort = 0;
static uint16_t gTcpPort = 0;

static void ensureWifi(const char *ssid, const char *password)
{
    uint8_t spin;

    if (gWifiReady) {
        return;
    }

    WiFi.begin(ssid, password);
    for (spin = 0; spin < 40; spin++) {
        if (WiFi.status() == WL_CONNECTED) {
            gWifiReady = true;
            return;
        }
        delay(250);
    }
}

static void ensureUdp(uint16_t localPort)
{
    if (gUdpReady && gUdpPort == localPort) {
        return;
    }
    gUdp.stop();
    gUdp.begin(localPort);
    gUdpPort = localPort;
    gUdpReady = true;
}

static void ensureTcp(const char *host, uint16_t port)
{
    if (gClient.connected() && gTcpPort == port) {
        return;
    }
    gClient.stop();
    gClient.connect(host, port);
    gTcpPort = port;
}
#endif

extern "C" {

void arduinopioWifiSetup(const char *ssid, const char *password)
{
#if defined(ARDUINOPIO_HAS_WIFI)
    ensureWifi(ssid, password);
#else
    (void)ssid;
    (void)password;
#endif
}

void arduinopioWifiUdpSend(const char *host, uint16_t port, const uint8_t *data, uint8_t length)
{
#if defined(ARDUINOPIO_HAS_WIFI)
    if (!gWifiReady) {
        return;
    }
    gUdp.beginPacket(host, port);
    gUdp.write(data, length);
    gUdp.endPacket();
#else
    (void)host;
    (void)port;
    (void)data;
    (void)length;
#endif
}

uint8_t arduinopioWifiUdpReceive(uint16_t localPort, uint8_t *data, uint8_t length)
{
#if defined(ARDUINOPIO_HAS_WIFI)
    int packetSize;
    int readCount;

    if (!gWifiReady) {
        return 0;
    }
    ensureUdp(localPort);
    packetSize = gUdp.parsePacket();
    if (packetSize <= 0) {
        return 0;
    }
    readCount = gUdp.read(data, length);
    if (readCount < 0) {
        return 0;
    }
    return (uint8_t)readCount;
#else
    (void)localPort;
    (void)data;
    (void)length;
    return 0;
#endif
}

void arduinopioWifiTcpSend(const char *host, uint16_t port, const uint8_t *data, uint8_t length)
{
#if defined(ARDUINOPIO_HAS_WIFI)
    if (!gWifiReady) {
        return;
    }
    ensureTcp(host, port);
    if (gClient.connected()) {
        gClient.write(data, length);
    }
#else
    (void)host;
    (void)port;
    (void)data;
    (void)length;
#endif
}

uint8_t arduinopioWifiTcpReceive(const char *host, uint16_t port, uint8_t *data, uint8_t length)
{
#if defined(ARDUINOPIO_HAS_WIFI)
    int availableCount;
    int index;

    if (!gWifiReady) {
        return 0;
    }
    ensureTcp(host, port);
    availableCount = gClient.available();
    if (availableCount <= 0) {
        return 0;
    }
    if (availableCount > (int)length) {
        availableCount = (int)length;
    }
    for (index = 0; index < availableCount; index++) {
        data[index] = (uint8_t)gClient.read();
    }
    return (uint8_t)availableCount;
#else
    (void)host;
    (void)port;
    (void)data;
    (void)length;
    return 0;
#endif
}

}
