function info = nano()
%nano Capability and pin map for Arduino Nano (ATmega328P).

    info = arduinopio.boards.uno();
    info.Name = "nano";
    info.DisplayName = "Arduino Nano";
    info.Mcu = "ATmega328P";
    info.Architecture = "avr";
    info.Implemented = true;
    info.AnalogPins = 0:7;
    info.Notes = [ ...
        "Classic Nano / ATmega328P only. A6 and A7 are analog-only."
        "Prefer a WDT FreeRTOS tick so Timer1 and Timer2 stay available for PWM."
        "Timer1 is shared by PWM pins 9/10, Servo, and Input Capture on D8."
        "CAN uses an MCP2515 on SPI. Default CS is pin 10; INT is unused because receive polls."];
end
