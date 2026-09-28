#ifndef ARDUINOPIO_ARDUINO_H
#define ARDUINOPIO_ARDUINO_H

#ifdef __cplusplus
#include <Arduino.h>
#else
#include <stdint.h>

#if defined(ESP32) || defined(ARDUINO_ARCH_ESP32)
#ifndef LOW
#define LOW 0x0
#endif
#ifndef HIGH
#define HIGH 0x1
#endif
#ifndef INPUT
#define INPUT 0x01
#endif
#ifndef OUTPUT
#define OUTPUT 0x03
#endif
#ifndef INPUT_PULLUP
#define INPUT_PULLUP 0x05
#endif
#ifndef INPUT_PULLDOWN
#define INPUT_PULLDOWN 0x09
#endif
#else
#ifndef LOW
#define LOW 0x0
#endif
#ifndef HIGH
#define HIGH 0x1
#endif
#ifndef INPUT
#define INPUT 0x0
#endif
#ifndef OUTPUT
#define OUTPUT 0x1
#endif
#ifndef INPUT_PULLUP
#define INPUT_PULLUP 0x2
#endif
#if defined(ARDUINO_ARCH_SAMD) || defined(ARDUINO_ARCH_SAM) || defined(ARDUINO_ARCH_NRF52) || defined(ARDUINO_ARCH_RENESAS) || defined(ARDUINO_ARCH_MBED)
#ifndef INPUT_PULLDOWN
#define INPUT_PULLDOWN 0x3
#endif
#endif
#endif

void pinMode(uint8_t pin, uint8_t mode);
void digitalWrite(uint8_t pin, uint8_t val);
int digitalRead(uint8_t pin);
int analogRead(uint8_t pin);
void analogWrite(uint8_t pin, int val);
#endif

#endif
