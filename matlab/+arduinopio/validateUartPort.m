function validateUartPort(port)
%validateUartPort Error if PORT is not a valid UART index on the active board.
    arguments
        port (1,1) {mustBeNumeric, mustBeInteger, mustBeNonnegative}
    end

    info = arduinopio.boards.getBoard();
    if port >= info.UartCount
        error("arduinopio:InvalidUart", ...
            "%s has %d UART(s). Port must be in 0:%d.", ...
            info.DisplayName, info.UartCount, info.UartCount-1);
    end
end
