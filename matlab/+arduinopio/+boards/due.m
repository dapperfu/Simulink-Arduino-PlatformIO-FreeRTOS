function info = due()
%DUE - Pin map for Arduino Due (AT91SAM3X8E).
%   Starts from the Uno map, then sets SAM3X pins, 12-bit DAC0/DAC1, four
%   UARTs, and two native CAN controllers. Package path: arduinopio.boards.due.
%
%   Syntax:
%       info = arduinopio.boards.due()
%
%   Inputs:
%       none
%
%   Outputs:
%       info - struct. Implemented true, DacPins [66 67], CanControllerCount 2,
%           UartCount 4, EepromSize 0.
%
%   Example:
%       info = arduinopio.boards.due();
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
    info.Name = "due";
    info.DisplayName = "Arduino Due";
    info.Mcu = "AT91SAM3X8E";
    info.Architecture = "sam";
    info.Implemented = true;
    info.DigitalPins = 0:53;
    info.AnalogPins = 0:11;
    info.AnalogAsDigitalPins = double.empty(1, 0);
    info.PwmPins = [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13];
    info.InterruptPins = 0:53;
    info.CapturePins = double.empty(1, 0);
    info.UartCount = 4;
    info.EepromSize = 0;
    info.AdcBits = 12;
    info.HasInputPulldown = true;
    info.HasDac = true;
    info.DacPins = [66, 67];
    info.DacBits = 12;
    info.HasOnboardCan = true;
    info.HasMcp2515 = false;
    info.CanControllerCount = 2;
    info.PwmTimers = struct("Pin", {}, "Timer", {}, "Channel", {});
    info.ExtraBlocks = ["DAC Write", "Onboard CAN Transmit", "Onboard CAN Receive", "Serial1-3"];
    info.Notes = [ ...
        "SAM3X8E. DAC0 is pin 66 and DAC1 is pin 67, 12-bit analogWrite."
        "Native CAN controllers are Can0 and Can1."
        "Serial, Serial1, Serial2, and Serial3 are ports 0-3."
        "Due has no EEPROM."];
end
