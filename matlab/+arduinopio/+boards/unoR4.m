function info = unoR4()
%UNOR4 - Stub capability data for Arduino Uno R4 Minima/WiFi (not classic Uno R3).
%   Starts from the Uno map, then marks Implemented false and sets Renesas RA4M1
%   features. Pin lists remain the Uno baseline until a dedicated map exists.
%   Package path: arduinopio.boards.unoR4.
%
%   Syntax:
%       info = arduinopio.boards.unoR4()
%
%   Inputs:
%       none
%
%   Outputs:
%       info - struct based on uno() with overrides:
%           Name - "unoR4"; DisplayName - "Arduino Uno R4"; Mcu - "RA4M1";
%           Architecture - "renesas"; Implemented - false;
%           HasInputPulldown - true; HasDac - true; HasOnboardCan - true;
%           HasLedMatrix - true; HasWifi - true; EepromSize - 0;
%           ExtraBlocks - Analog Output, On-board CAN, 12x8 LED Matrix, WiFi.
%           Inherited pin/UART focus: DigitalPins 0:19, PwmPins [3,5,6,9,10,11],
%           UartCount 1 (from Uno baseline).
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
%   28-Sep-2026; Last revision: 28-Sep-2026

%------------- BEGIN CODE --------------
    info = arduinopio.boards.uno();
    info.Name = "unoR4";
    info.DisplayName = "Arduino Uno R4";
    info.Mcu = "RA4M1";
    info.Architecture = "renesas";
    info.Implemented = false;
    info.HasInputPulldown = true;
    info.HasDac = true;
    info.HasOnboardCan = true;
    info.HasLedMatrix = true;
    info.HasWifi = true;
    info.EepromSize = 0;
    info.ExtraBlocks = ["Analog Output", "On-board CAN", "12x8 LED Matrix", "WiFi (WiFi model)"];
end
