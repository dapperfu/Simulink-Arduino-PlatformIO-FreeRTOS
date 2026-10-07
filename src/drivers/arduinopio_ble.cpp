#include "arduinopio_ble.h"

#include <Arduino.h>
#include <string>
#include <string.h>

#if defined(ARDUINO_ARCH_ESP32)
#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#define ARDUINOPIO_BLE_ESP32 1
#elif defined(ARDUINO_ARCH_SAMD) || defined(ARDUINO_ARCH_NRF52) || defined(ARDUINO_ARCH_MBED)
#include <ArduinoBLE.h>
#define ARDUINOPIO_BLE_ARDUINO 1
#endif

#if defined(ARDUINOPIO_BLE_ESP32)
static BLECharacteristic *gCharacteristic = nullptr;
static bool gBleReady = false;
#elif defined(ARDUINOPIO_BLE_ARDUINO)
static char gServiceUuid[40];
static char gCharacteristicUuid[40];
static BLEService *gService = nullptr;
static BLECharacteristic *gCharacteristic = nullptr;
static bool gBleReady = false;
alignas(BLEService) static uint8_t gServiceMemory[sizeof(BLEService)];
alignas(BLECharacteristic) static uint8_t gCharacteristicMemory[sizeof(BLECharacteristic)];
#endif

static void copyText(char *destination, const char *source, size_t capacity)
{
    size_t length = 0;

    if (source != nullptr) {
        length = strlen(source);
        if (length >= capacity) {
            length = capacity - 1U;
        }
        memcpy(destination, source, length);
    }
    destination[length] = '\0';
}

extern "C" {

void arduinopioBleSetup(const char *deviceName, const char *serviceUuid, const char *characteristicUuid)
{
#if defined(ARDUINOPIO_BLE_ESP32)
    BLEServer *server;
    BLEService *service;
    BLEAdvertising *advertising;

    if (gBleReady) {
        return;
    }
    BLEDevice::init(deviceName);
    server = BLEDevice::createServer();
    service = server->createService(serviceUuid);
    gCharacteristic = service->createCharacteristic(
        characteristicUuid,
        BLECharacteristic::PROPERTY_READ | BLECharacteristic::PROPERTY_WRITE | BLECharacteristic::PROPERTY_NOTIFY);
    gCharacteristic->setValue("");
    service->start();
    advertising = BLEDevice::getAdvertising();
    advertising->addServiceUUID(serviceUuid);
    BLEDevice::startAdvertising();
    gBleReady = true;
#elif defined(ARDUINOPIO_BLE_ARDUINO)
    if (gBleReady) {
        return;
    }
    copyText(gServiceUuid, serviceUuid, sizeof(gServiceUuid));
    copyText(gCharacteristicUuid, characteristicUuid, sizeof(gCharacteristicUuid));
    if (!BLE.begin()) {
        return;
    }
    gService = new (gServiceMemory) BLEService(gServiceUuid);
    gCharacteristic = new (gCharacteristicMemory) BLECharacteristic(
        gCharacteristicUuid, BLERead | BLEWrite | BLENotify, 20);
    BLE.setLocalName(deviceName);
    BLE.setAdvertisedService(*gService);
    gService->addCharacteristic(*gCharacteristic);
    BLE.addService(*gService);
    BLE.advertise();
    gBleReady = true;
#else
    (void)deviceName;
    (void)serviceUuid;
    (void)characteristicUuid;
#endif
}

void arduinopioBleWrite(const uint8_t *data, uint8_t length)
{
#if defined(ARDUINOPIO_BLE_ESP32)
    if (!gBleReady || gCharacteristic == nullptr) {
        return;
    }
    gCharacteristic->setValue((uint8_t *)data, length);
    gCharacteristic->notify();
#elif defined(ARDUINOPIO_BLE_ARDUINO)
    if (!gBleReady || gCharacteristic == nullptr) {
        return;
    }
    BLE.poll();
    gCharacteristic->writeValue(data, length);
#else
    (void)data;
    (void)length;
#endif
}

uint8_t arduinopioBleRead(uint8_t *data, uint8_t length)
{
#if defined(ARDUINOPIO_BLE_ESP32)
    std::string value;
    uint8_t count;
    uint8_t index;

    if (!gBleReady || gCharacteristic == nullptr || length == 0U) {
        return 0;
    }
    value = gCharacteristic->getValue();
    count = (uint8_t)value.length();
    if (count > length) {
        count = length;
    }
    for (index = 0; index < count; index++) {
        data[index] = (uint8_t)value[index];
    }
    return count;
#elif defined(ARDUINOPIO_BLE_ARDUINO)
    int valueLength;
    int count;

    if (!gBleReady || gCharacteristic == nullptr) {
        return 0;
    }
    BLE.poll();
    if (!gCharacteristic->written()) {
        return 0;
    }
    valueLength = gCharacteristic->valueLength();
    if (valueLength <= 0) {
        return 0;
    }
    count = valueLength > (int)length ? (int)length : valueLength;
    memcpy(data, gCharacteristic->value(), (size_t)count);
    return (uint8_t)count;
#else
    (void)data;
    (void)length;
    return 0;
#endif
}

}
