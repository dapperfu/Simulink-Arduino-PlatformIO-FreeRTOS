function info = nano33Ble()
%NANO33BLE - Stub capability data for Arduino Nano 33 BLE Sense.
%   Starts from the Uno map, then marks Implemented false and sets nRF52840
%   features. Pin lists remain the Uno baseline until a dedicated map exists.
%   Package path: arduinopio.boards.nano33Ble.
%
%   Syntax:
%       info = arduinopio.boards.nano33Ble()
%
%   Inputs:
%       none
%
%   Outputs:
%       info - struct based on uno() with overrides:
%           Name - "nano33Ble"; DisplayName - "Arduino Nano 33 BLE Sense";
%           Mcu - "nRF52840"; Architecture - "nrf52"; Implemented - false;
%           HasInputPulldown - true; HasDac - true; HasBle - true;
%           EepromSize - 0; ExtraBlocks - Analog Output, BLE Receive/Transmit.
%           Inherited: DigitalPins 0:19, PwmPins [3,5,6,9,10,11], UartCount 1.
%
%   Example:
%       info = arduinopio.boards.nano33Ble();
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
    info.Name = "nano33Ble";
    info.DisplayName = "Arduino Nano 33 BLE Sense";
    info.Mcu = "nRF52840";
    info.Architecture = "nrf52";
    info.Implemented = false;
    info.HasInputPulldown = true;
    info.HasDac = true;
    info.HasBle = true;
    info.EepromSize = 0;
    info.ExtraBlocks = ["Analog Output", "BLE Receive", "BLE Transmit"];
end
