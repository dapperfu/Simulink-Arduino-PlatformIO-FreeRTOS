function validateUartPortOnHost(port)
%validateUartPortOnHost MATLAB-only UART index check against the active board.

    info = arduinopio.boards.getBoard();
    if port >= info.UartCount
        error("arduinopio:InvalidUart", ...
            "%s has %d UART(s). Port must be in 0:%d.", ...
            info.DisplayName, info.UartCount, info.UartCount-1);
    end
end
