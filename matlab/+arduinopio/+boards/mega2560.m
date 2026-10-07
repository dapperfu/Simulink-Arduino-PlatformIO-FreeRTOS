function info = mega2560()
%MEGA2560 - Pin map for Arduino Mega 2560 (ATmega2560).
%   Starts from the Uno map, then replaces the pin ranges, UART count, EEPROM,
%   SPI, and I2C pins with the Mega 2560 map. Package path:
%   arduinopio.boards.mega2560.
%
%   Syntax:
%       info = arduinopio.boards.mega2560()
%
%   Inputs:
%       none
%
%   Outputs:
%       info - struct. DigitalPins 0:69, AnalogPins 0:15, PwmPins 2:13,
%           UartCount 4, EepromSize 4096, Implemented true.
%
%   Example:
%       info = arduinopio.boards.mega2560();
%
%   Other m-files required: arduinopio.boards.uno
%   Subfunctions: none
%   MAT-files required: none
%
%   See also: UNO, GETBOARD, LISTBOARDS

%   Author: Frey, Jed
%   07-Oct-2026; Last revision: 07-Oct-2026

%------------- BEGIN CODE --------------
    info = arduinopio.boards.uno();
    info.Name = "mega2560";
    info.DisplayName = "Arduino Mega 2560";
    info.Mcu = "ATmega2560";
    info.Architecture = "avr";
    info.Implemented = true;
    info.DigitalPins = 0:69;
    info.AnalogPins = 0:15;
    info.AnalogAsDigitalPins = 54:69;
    info.PwmPins = 2:13;
    info.InterruptPins = [2, 3, 18, 19, 20, 21];
    info.CapturePins = [48, 49];
    info.SpiPins = struct("Ss", 53, "Mosi", 51, "Miso", 50, "Sck", 52);
    info.I2cPins = struct("Sda", 20, "Scl", 21);
    info.UartCount = 4;
    info.UartPins = struct("Rx", [0, 19, 17, 15], "Tx", [1, 18, 16, 14]);
    info.EepromSize = 4096;
    info.AdcBits = 10;
    info.HasMcp2515 = false;
    info.BuiltinLedPin = 13;
    info.PwmTimers = struct("Pin", {}, "Timer", {}, "Channel", {});
    info.ExtraBlocks = ["Serial1", "Serial2", "Serial3", "Analog Input", "PWM"];
    info.Notes = [ ...
        "ATmega2560. Analog pins A0-A15 are digital 54-69."
        "Serial1 is RX19/TX18, Serial2 is RX17/TX16, Serial3 is RX15/TX14."
        "PWM pins are 2 through 13. EEPROM is 4096 bytes."];
end
