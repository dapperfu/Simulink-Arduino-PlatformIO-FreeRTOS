function info = mega2560()
%MEGA2560 - Stub capability data for Arduino Mega 2560. Drivers not implemented.
%   Uses stubBoard to copy the Uno map with Mega identity, then overrides pin
%   ranges, UART count, EEPROM size, architecture, and ExtraBlocks. Package
%   path: arduinopio.boards.mega2560.
%
%   Syntax:
%       info = arduinopio.boards.mega2560()
%
%   Inputs:
%       none
%
%   Outputs:
%       info - struct with Mega overrides on the Uno baseline:
%           Name - "mega2560"; DisplayName - "Arduino Mega 2560";
%           Mcu - "ATmega2560"; Architecture - "avr"; Implemented - false;
%           DigitalPins - 0:69; AnalogPins - 0:15;
%           PwmPins - [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13];
%           UartCount - 4; EepromSize - 4096;
%           ExtraBlocks - Serial1, Serial2, Serial3.
%           Other fields (e.g. PwmTimers, InterruptPins) still from Uno until
%           a full Mega map is written.
%
%   Example:
%       info = arduinopio.boards.mega2560();
%
%   Other m-files required: arduinopio.boards.uno
%   Subfunctions: stubBoard
%   MAT-files required: none
%
%   See also: UNO, GETBOARD, LISTBOARDS

%   Author: Frey, Jed
%   28-Sep-2026; Last revision: 28-Sep-2026

%------------- BEGIN CODE --------------
    info = stubBoard("mega2560", "Arduino Mega 2560", "ATmega2560");
    info.DigitalPins = 0:69;
    info.AnalogPins = 0:15;
    info.PwmPins = [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13];
    info.UartCount = 4;
    info.EepromSize = 4096;
    info.Architecture = "avr";
    info.ExtraBlocks = ["Serial1", "Serial2", "Serial3"];
end

function info = stubBoard(name, displayName, mcu)
%STUBBOARD - Copy the Uno board map and mark it unimplemented with new identity.
%   Sets Name, DisplayName, Mcu, and Implemented false on arduinopio.boards.uno.
%
%   Syntax:
%       info = stubBoard(name, displayName, mcu)
%
%   Inputs:
%       name - string. Board Name field (e.g. "mega2560").
%       displayName - string. Human-readable DisplayName.
%       mcu - string. MCU identifier string.
%
%   Outputs:
%       info - struct. Uno capability map with identity fields replaced.
%
%   Example:
%       info = stubBoard("mega2560", "Arduino Mega 2560", "ATmega2560");
%
%   See also: MEGA2560, UNO
    info = arduinopio.boards.uno();
    info.Name = name;
    info.DisplayName = displayName;
    info.Mcu = mcu;
    info.Implemented = false;
end
