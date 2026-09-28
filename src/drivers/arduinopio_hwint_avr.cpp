#include "arduinopio_hwint_avr.h"

#include <Arduino.h>

#if defined(__AVR_ATmega328P__) || defined(__AVR_ATmega328__)

/* Source 0: Timer1 overflow, 1: Timer1 compare A, 2: Timer2 overflow, 3: ADC complete.
   Timer0 overflow and USART RX stay with the Arduino core. */
static volatile uint8_t gHwIntCount[4];

ISR(TIMER1_OVF_vect)
{
    gHwIntCount[0]++;
}

ISR(TIMER1_COMPA_vect)
{
    gHwIntCount[1]++;
}

ISR(TIMER2_OVF_vect)
{
    gHwIntCount[2]++;
}

ISR(ADC_vect)
{
    gHwIntCount[3]++;
}

#endif

extern "C" {

void arduinopioHwIntAvrSetup(uint8_t sourceId)
{
#if defined(__AVR_ATmega328P__) || defined(__AVR_ATmega328__)
    switch (sourceId) {
    case 0:
        TIMSK1 |= (1 << TOIE1);
        break;
    case 1:
        TIMSK1 |= (1 << OCIE1A);
        break;
    case 2:
        TIMSK2 |= (1 << TOIE2);
        break;
    case 3:
        ADCSRA |= (1 << ADIE);
        break;
    default:
        break;
    }
#else
    (void)sourceId;
#endif
}

uint8_t arduinopioHwIntAvrTake(uint8_t sourceId)
{
    uint8_t pending = 0;

#if defined(__AVR_ATmega328P__) || defined(__AVR_ATmega328__)
    if (sourceId > 3) {
        return 0;
    }
    noInterrupts();
    if (gHwIntCount[sourceId] > 0) {
        gHwIntCount[sourceId]--;
        pending = 1;
    }
    interrupts();
#else
    (void)sourceId;
#endif
    return pending;
}

}
