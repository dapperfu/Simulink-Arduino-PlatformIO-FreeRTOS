function info = due()
%DUE - Stub capability data for Arduino Due. Drivers are not implemented yet.
%   Starts from the Uno map, then marks Implemented false and sets SAM3X UART,
%   EEPROM, and on-board CAN flags. Digital/PWM pin lists remain Uno baseline.
%   Package path: arduinopio.boards.due.
%
%   Syntax:
%       info = arduinopio.boards.due()
%
%   Inputs:
%       none
%
%   Outputs:
%       info - struct based on uno() with overrides:
%           Name - "due"; DisplayName - "Arduino Due"; Mcu - "AT91SAM3X8E";
%           Architecture - "sam"; Implemented - false;
%           HasInputPulldown - true; HasDac - true; UartCount - 4;
%           EepromSize - 0; HasOnboardCan - true;
%           ExtraBlocks - Analog Output, On-board CAN Receive/Transmit, Serial1-3.
%           Inherited: DigitalPins 0:19, PwmPins [3,5,6,9,10,11] (Uno baseline).
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
%   28-Sep-2026; Last revision: 28-Sep-2026

%------------- BEGIN CODE --------------
    info = arduinopio.boards.uno();
    info.Name = "due";
    info.DisplayName = "Arduino Due";
    info.Mcu = "AT91SAM3X8E";
    info.Architecture = "sam";
    info.Implemented = false;
    info.HasInputPulldown = true;
    info.HasDac = true;
    info.UartCount = 4;
    info.EepromSize = 0;
    info.HasOnboardCan = true;
    info.ExtraBlocks = ["Analog Output", "On-board CAN Receive", "On-board CAN Transmit", "Serial1-3"];
end
