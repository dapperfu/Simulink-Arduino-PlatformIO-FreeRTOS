function info = getBoard(boardId)
%getBoard Return board capability data. Defaults to Uno R3.

    arguments
        boardId (1,1) string = ""
    end

    if boardId == ""
        boardId = resolveActiveBoardId();
    end

    switch lower(boardId)
        case {"uno", "arduino uno", "arduino uno r3", "uno r3"}
            info = arduinopio.boards.uno();
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
    boardId = "uno";
    try
        modelName = bdroot;
        if strlength(string(modelName)) == 0
            return
        end
        hardwareBoard = string(get_param(modelName, "HardwareBoard"));
        if hardwareBoard ~= "" && hardwareBoard ~= "None"
            boardId = hardwareBoard;
        end
    catch
        % No model is loaded, or the parameter is unavailable. Keep Uno.
    end
end
