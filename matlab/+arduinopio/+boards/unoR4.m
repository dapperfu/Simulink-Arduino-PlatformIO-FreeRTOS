function info = unoR4()
%UNOR4 - Pin map for Arduino Uno R4 WiFi (RA4M1), not classic Uno R3.
%   Keeps the Uno digital pin numbering, then adds the 12-bit DAC on A0,
%   one native CAN controller, the 12x8 LED matrix, and WiFiS3. Package path:
%   arduinopio.boards.unoR4.
%
%   Syntax:
%       info = arduinopio.boards.unoR4()
%
%   Inputs:
%       none
%
%   Outputs:
%       info - struct. Implemented true, DacPins 14, CanControllerCount 1,
%           HasLedMatrix true, HasWifi true.
%
%   Example:
%       info = arduinopio.boards.unoR4();
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
    info.Name = "unoR4";
    info.DisplayName = "Arduino Uno R4 WiFi";
    info.Mcu = "RA4M1";
    info.Architecture = "renesas";
    info.Implemented = true;
    info.AdcBits = 14;
    info.EepromSize = 0;
    info.HasInputPulldown = true;
    info.HasDac = true;
    info.DacPins = 14;
    info.DacBits = 12;
    info.HasOnboardCan = true;
    info.HasMcp2515 = false;
    info.CanControllerCount = 1;
    info.HasLedMatrix = true;
    info.HasWifi = true;
    info.PwmTimers = struct("Pin", {}, "Timer", {}, "Channel", {});
    info.ExtraBlocks = ["DAC Write", "Onboard CAN", "LED Matrix", "WiFi"];
    info.Notes = [ ...
        "Renesas RA4M1 Uno R4 WiFi. A0 is digital pin 14 and is the 12-bit DAC."
        "Native CAN uses the Arduino_CAN library."
        "The 12x8 LED matrix accepts 12 column bytes. Bit 0 of each byte is row 0."
        "WiFi uses WiFiS3 and is present on the WiFi model."
        "This board has no EEPROM."];
end
