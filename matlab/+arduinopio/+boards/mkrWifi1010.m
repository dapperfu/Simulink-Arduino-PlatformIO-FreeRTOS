function info = mkrWifi1010()
%MKRWIFI1010 - Pin map for Arduino MKR WiFi 1010 (SAMD21).
%   Starts from the Uno map, then sets SAMD21 pins, a 10-bit DAC on A0
%   (digital pin 15), WiFiNINA, and ArduinoBLE. Package path:
%   arduinopio.boards.mkrWifi1010.
%
%   Syntax:
%       info = arduinopio.boards.mkrWifi1010()
%
%   Inputs:
%       none
%
%   Outputs:
%       info - struct. Implemented true, DacPins 15, HasWifi true, HasBle true.
%
%   Example:
%       info = arduinopio.boards.mkrWifi1010();
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
    info.Name = "mkrWifi1010";
    info.DisplayName = "Arduino MKR WiFi 1010";
    info.Mcu = "SAMD21";
    info.Architecture = "samd";
    info.Implemented = true;
    info.DigitalPins = 0:21;
    info.AnalogPins = 15:21;
    info.AnalogAsDigitalPins = 15:21;
    info.PwmPins = [0, 1, 2, 3, 4, 5, 6, 7, 8, 10, 18, 19];
    info.InterruptPins = 0:21;
    info.CapturePins = double.empty(1, 0);
    info.UartCount = 2;
    info.EepromSize = 0;
    info.AdcBits = 12;
    info.HasInputPulldown = true;
    info.HasDac = true;
    info.DacPins = 15;
    info.DacBits = 10;
    info.HasWifi = true;
    info.HasBle = true;
    info.HasMcp2515 = false;
    info.PwmTimers = struct("Pin", {}, "Timer", {}, "Channel", {});
    info.ExtraBlocks = ["DAC Write", "WiFi UDP", "WiFi TCP", "BLE Transmit", "BLE Receive"];
    info.Notes = [ ...
        "SAMD21. A0 is digital pin 15 and is the 10-bit DAC."
        "Analog pins A0-A6 are digital pins 15-21."
        "WiFi uses the WiFiNINA library. BLE uses ArduinoBLE."
        "This board has no EEPROM."];
end
