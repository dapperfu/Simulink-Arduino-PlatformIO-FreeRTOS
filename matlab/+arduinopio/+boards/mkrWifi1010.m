function info = mkrWifi1010()
%MKRWIFI1010 - Stub capability data for Arduino MKR WiFi 1010.
%   Starts from the Uno map, then marks Implemented false and sets SAMD21
%   features. Pin lists remain the Uno baseline until a dedicated map exists.
%   Package path: arduinopio.boards.mkrWifi1010.
%
%   Syntax:
%       info = arduinopio.boards.mkrWifi1010()
%
%   Inputs:
%       none
%
%   Outputs:
%       info - struct based on uno() with overrides:
%           Name - "mkrWifi1010"; DisplayName - "Arduino MKR WiFi 1010";
%           Mcu - "SAMD21"; Architecture - "samd"; Implemented - false;
%           HasInputPulldown - true; HasDac - true; HasWifi - true; HasBle - true;
%           EepromSize - 0; ExtraBlocks - Analog Output, WiFi TCP/UDP, BLE
%           Receive/Transmit.
%           Inherited: DigitalPins 0:19, PwmPins [3,5,6,9,10,11], UartCount 1.
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
%   28-Sep-2026; Last revision: 28-Sep-2026

%------------- BEGIN CODE --------------
    info = arduinopio.boards.uno();
    info.Name = "mkrWifi1010";
    info.DisplayName = "Arduino MKR WiFi 1010";
    info.Mcu = "SAMD21";
    info.Architecture = "samd";
    info.Implemented = false;
    info.HasInputPulldown = true;
    info.HasDac = true;
    info.HasWifi = true;
    info.HasBle = true;
    info.EepromSize = 0;
    info.ExtraBlocks = ["Analog Output", "WiFi TCP/UDP", "BLE Receive", "BLE Transmit"];
end
