function names = listBoards()
%LISTBOARDS - Return implemented and stub board identifiers in this package.
%   Lists the board map function names under arduinopio.boards. Package path:
%   arduinopio.boards.listBoards.
%
%   Syntax:
%       names = arduinopio.boards.listBoards()
%
%   Inputs:
%       none
%
%   Outputs:
%       names - string column. uno, nano, mega2560, due, mkrWifi1010,
%           esp32Wroom, unoR4, nano33Ble.
%
%   Example:
%       names = arduinopio.boards.listBoards();
%
%   Other m-files required: none
%   Subfunctions: none
%   MAT-files required: none
%
%   See also: GETBOARD, UNO

%   Author: Frey, Jed
%   28-Sep-2026; Last revision: 28-Sep-2026

%------------- BEGIN CODE --------------
    names = [ ...
        "uno"
        "nano"
        "mega2560"
        "due"
        "mkrWifi1010"
        "esp32Wroom"
        "unoR4"
        "nano33Ble"];
end
