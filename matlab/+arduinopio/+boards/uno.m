function info = uno()
%UNO - Capability and pin map for Arduino Uno R3 (ATmega328P).
%   Returns the reference board struct used by other maps and by getBoard when
%   the default board is selected. Implemented AVR map with MCP2515 CAN support.
%   Package path: arduinopio.boards.uno.
%
%   Syntax:
%       info = arduinopio.boards.uno()
%
%   Inputs:
%       none
%
%   Outputs:
%       info - struct with fields:
%           Name - "uno"; DisplayName - "Arduino Uno R3"; Mcu - "ATmega328P";
%           Architecture - "avr"; Implemented - true;
%           DigitalPins - 0:19; AnalogPins - 0:5; AnalogAsDigitalPins - 14:19;
%           PwmPins - [3, 5, 6, 9, 10, 11]; InterruptPins - [2, 3];
%           CapturePins - 8; SpiPins - Ss/Mosi/Miso/Sck 10/11/12/13;
%           I2cPins - Sda/Scl 18/19; UartCount - 1; UartPins - Rx/Tx 0/1;
%           EepromSize - 1024; AdcBits - 10;
%           HasInputPulldown/HasDac/HasBle/HasWifi/HasOnboardCan/HasLedMatrix -
%           false; HasMcp2515 - true; BuiltinLedPin - 13;
%           PwmTimers - Pin/Timer/Channel for pins 3,5,6,9,10,11 (timers 2,0,0,
%           1,1,2); ExtraBlocks - empty string; Notes - WDT/timer/CAN notes.
%
%   Example:
%       info = arduinopio.boards.uno();
%
%   Other m-files required: none
%   Subfunctions: none
%   MAT-files required: none
%
%   See also: GETBOARD, NANO, TIMERFORPWMPIN, LISTBOARDS

%   Author: Frey, Jed
%   28-Sep-2026; Last revision: 28-Sep-2026

%------------- BEGIN CODE --------------
    info = struct();
    info.Name = "uno";
    info.DisplayName = "Arduino Uno R3";
    info.Mcu = "ATmega328P";
    info.Architecture = "avr";
    info.Implemented = true;
    info.DigitalPins = 0:19;
    info.AnalogPins = 0:5;
    info.AnalogAsDigitalPins = 14:19;
    info.PwmPins = [3, 5, 6, 9, 10, 11];
    info.InterruptPins = [2, 3];
    info.CapturePins = 8;
    info.SpiPins = struct("Ss", 10, "Mosi", 11, "Miso", 12, "Sck", 13);
    info.I2cPins = struct("Sda", 18, "Scl", 19);
    info.UartCount = 1;
    info.UartPins = struct("Rx", 0, "Tx", 1);
    info.EepromSize = 1024;
    info.AdcBits = 10;
    info.HasInputPulldown = false;
    info.HasDac = false;
    info.HasBle = false;
    info.HasWifi = false;
    info.HasOnboardCan = false;
    info.HasMcp2515 = true;
    info.HasLedMatrix = false;
    info.DacPins = double.empty(1, 0);
    info.DacBits = 0;
    info.TouchPins = double.empty(1, 0);
    info.CanControllerCount = 0;
    info.BuiltinLedPin = 13;
    info.PwmTimers = [ ...
        struct("Pin", 3, "Timer", 2, "Channel", "B"), ...
        struct("Pin", 5, "Timer", 0, "Channel", "B"), ...
        struct("Pin", 6, "Timer", 0, "Channel", "A"), ...
        struct("Pin", 9, "Timer", 1, "Channel", "A"), ...
        struct("Pin", 10, "Timer", 1, "Channel", "B"), ...
        struct("Pin", 11, "Timer", 2, "Channel", "A")];
    info.ExtraBlocks = string.empty(1, 0);
    info.Notes = [ ...
        "Classic Uno R3 / ATmega328P only."
        "Prefer a WDT FreeRTOS tick so Timer1 and Timer2 stay available for PWM."
        "Timer1 is shared by PWM pins 9/10, Servo, and Input Capture on D8."
        "CAN uses an MCP2515 on SPI. Default CS is pin 10; INT is unused because receive polls."];
end
