function info = esp32Wroom()
%ESP32WROOM - Stub capability data for ESP32-WROOM.
%   Starts from the Uno map, then marks Implemented false and sets Xtensa ESP32
%   features. Pin lists remain the Uno baseline until a dedicated map exists.
%   Package path: arduinopio.boards.esp32Wroom.
%
%   Syntax:
%       info = arduinopio.boards.esp32Wroom()
%
%   Inputs:
%       none
%
%   Outputs:
%       info - struct based on uno() with overrides:
%           Name - "esp32Wroom"; DisplayName - "ESP32-WROOM";
%           Mcu - "ESP32-D0WDQ6"; Architecture - "xtensa"; Implemented - false;
%           HasInputPulldown - true; HasDac - true; HasWifi - true; HasBle - true;
%           EepromSize - 0; ExtraBlocks - Analog Output, WiFi TCP/UDP, BLE,
%           Touch Sense.
%           Inherited: DigitalPins 0:19, PwmPins [3,5,6,9,10,11], UartCount 1.
%
%   Example:
%       info = arduinopio.boards.esp32Wroom();
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
    info.Name = "esp32Wroom";
    info.DisplayName = "ESP32-WROOM";
    info.Mcu = "ESP32-D0WDQ6";
    info.Architecture = "xtensa";
    info.Implemented = false;
    info.HasInputPulldown = true;
    info.HasDac = true;
    info.HasWifi = true;
    info.HasBle = true;
    info.EepromSize = 0;
    info.ExtraBlocks = ["Analog Output", "WiFi TCP/UDP", "BLE", "Touch Sense"];
end
