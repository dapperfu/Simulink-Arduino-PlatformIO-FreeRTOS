function info = nano()
%NANO - Capability and pin map for Arduino Nano (ATmega328P).
%   Starts from the Uno map, then sets Nano identity and AnalogPins 0:7 (A6/A7
%   analog-only). Implemented AVR; same PWM timers and UART/EEPROM as Uno.
%   Package path: arduinopio.boards.nano.
%
%   Syntax:
%       info = arduinopio.boards.nano()
%
%   Inputs:
%       none
%
%   Outputs:
%       info - struct based on uno() with overrides:
%           Name - "nano"; DisplayName - "Arduino Nano"; Mcu - "ATmega328P";
%           Architecture - "avr"; Implemented - true; AnalogPins - 0:7;
%           Notes - Nano/WDT/Timer1/CAN notes.
%           Inherited from Uno: DigitalPins 0:19, PwmPins [3,5,6,9,10,11],
%           InterruptPins [2,3], CapturePins 8, UartCount 1, EepromSize 1024,
%           PwmTimers (pins 3/5/6/9/10/11 on timers 2/0/0/1/1/2), HasMcp2515 true.
%
%   Example:
%       info = arduinopio.boards.nano();
%
%   Other m-files required: arduinopio.boards.uno
%   Subfunctions: none
%   MAT-files required: none
%
%   See also: UNO, GETBOARD, LISTBOARDS

%   Author: Frey, Jed
%   28-Sep-2026; Last revision: 28-Sep-2026

%------------- BEGIN CODE --------------
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
