#include "arduinopio_adc_avr.h"

#include <Arduino.h>

#if defined(__AVR_ATmega328P__) || defined(__AVR_ATmega328__)

static uint8_t gAdcReference = 1;
static uint8_t gAdcPrescaler = 7;

static void applyAdcSettings(uint8_t pin)
{
    uint8_t channel = pin & 0x07;
    ADMUX = (uint8_t)((gAdcReference << 6) | channel);
    ADCSRA = (uint8_t)((1 << ADEN) | gAdcPrescaler);
}

#endif

extern "C" {

void arduinopioAdcAvrSetup(uint8_t pin, uint8_t referenceSelect, uint8_t prescalerSelect)
{
#if defined(__AVR_ATmega328P__) || defined(__AVR_ATmega328__)
    gAdcReference = referenceSelect & 0x03;
    gAdcPrescaler = prescalerSelect & 0x07;
    applyAdcSettings(pin);
#else
    analogReference(DEFAULT);
    (void)pin;
    (void)referenceSelect;
    (void)prescalerSelect;
#endif
}

uint16_t arduinopioAdcAvrRead(uint8_t pin)
{
    uint16_t value = 0;

#if defined(__AVR_ATmega328P__) || defined(__AVR_ATmega328__)
    applyAdcSettings(pin);
    ADCSRA |= (1 << ADSC);
    while ((ADCSRA & (1 << ADSC)) != 0) {
    }
    value = ADC;
#else
    value = (uint16_t)analogRead(pin);
#endif
    return value;
}

}
