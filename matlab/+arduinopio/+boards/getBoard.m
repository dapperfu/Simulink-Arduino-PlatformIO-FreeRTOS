function info = getBoard(boardId)
%GETBOARD - Return board capability data for a board id, defaulting to Uno R3.
%   Resolves aliases to a board map function under arduinopio.boards. Empty
%   boardId uses resolveActiveBoardId (PioBoard, then HardwareBoard, else "uno").
%   Unknown ids warn arduinopio:UnknownBoard and return the Uno map. Package
%   path: arduinopio.boards.getBoard.
%
%   Syntax:
%       info = arduinopio.boards.getBoard(boardId)
%       info = arduinopio.boards.getBoard()
%
%   Inputs:
%       boardId - (1,1) string. Board key or alias. Default "" (active model or
%           Uno). Aliases include uno, nano, mega2560, due, mkrWifi1010, esp32,
%           uno r4, nano33ble, and common display-name forms.
%
%   Outputs:
%       info - struct from the matching board function (e.g. Name, DisplayName,
%           Mcu, Architecture, Implemented, DigitalPins, AnalogPins, PwmPins,
%           UartCount, EepromSize, PwmTimers, feature flags). See UNO for the
%           full field set of the default map.
%
%   Example:
%       info = arduinopio.boards.getBoard("nano");
%
%   Other m-files required: arduinopio.boards.uno, nano, mega2560, due,
%       mkrWifi1010, esp32Wroom, unoR4, nano33Ble
%   Subfunctions: resolveActiveBoardId
%   MAT-files required: none
%
%   See also: LISTBOARDS, UNO, NANO, MEGA2560

%   Author: Frey, Jed
%   28-Sep-2026; Last revision: 28-Sep-2026

%------------- BEGIN CODE --------------
    arguments
        boardId (1,1) string = ""
    end

    if boardId == ""
        boardId = resolveActiveBoardId();
    end

    switch lower(boardId)
        case {"uno", "arduino uno", "arduino uno r3", "uno r3"}
            info = arduinopio.boards.uno();
        case {"nano", "arduino nano", "nanoatmega328", "nanoatmega328new"}
            info = arduinopio.boards.nano();
        case {"mega2560", "mega", "arduino mega 2560"}
            info = arduinopio.boards.mega2560();
        case {"due", "arduino due"}
            info = arduinopio.boards.due();
        case {"mkr", "mkrwifi1010", "arduino mkr wifi 1010"}
            info = arduinopio.boards.mkrWifi1010();
        case {"esp32", "esp32-wroom"}
            info = arduinopio.boards.esp32Wroom();
        case {"uno r4", "unor4", "uno r4 minima", "uno r4 wifi"}
            info = arduinopio.boards.unoR4();
        case {"nano33ble", "nano 33 ble"}
            info = arduinopio.boards.nano33Ble();
        otherwise
            warning("arduinopio:UnknownBoard", ...
                "Unknown board '%s'. Using Arduino Uno R3 pin map.", boardId);
            info = arduinopio.boards.uno();
    end
end

function boardId = resolveActiveBoardId()
%RESOLVEACTIVEBOARDID - Choose board id from the current model, else "uno".
%   Prefers nonempty PioBoard on bdroot, then HardwareBoard when set and not
%   "None". Returns "uno" if no model is loaded or parameters are unavailable.
%
%   Syntax:
%       boardId = resolveActiveBoardId()
%
%   Inputs:
%       none
%
%   Outputs:
%       boardId - string. Resolved board identifier for getBoard.
%
%   Example:
%       id = resolveActiveBoardId();
%
%   See also: GETBOARD
    boardId = "uno";
    try
        modelName = bdroot;
        if strlength(string(modelName)) == 0
            return
        end
    catch
        return
    end

    try
        pioBoard = string(get_param(modelName, "PioBoard"));
        if strlength(strip(pioBoard)) > 0
            boardId = pioBoard;
            return
        end
    catch
        % PioBoard is unavailable until this target is selected.
    end

    try
        hardwareBoard = string(get_param(modelName, "HardwareBoard"));
        if hardwareBoard ~= "" && hardwareBoard ~= "None"
            boardId = hardwareBoard;
        end
    catch
        % No model is loaded, or the parameter is unavailable. Keep Uno.
    end
end
