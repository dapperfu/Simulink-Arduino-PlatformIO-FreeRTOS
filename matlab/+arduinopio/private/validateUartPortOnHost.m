function validateUartPortOnHost(port)
%VALIDATEUARTPORTONHOST - Error if PORT is not a valid UART index on the board.
%   MATLAB-only. Compares port to getBoard().UartCount and errors
%   arduinopio:InvalidUart when port >= UartCount. Private; called from
%   validateUartPort via coder.extrinsic.
%
%   Syntax:
%       validateUartPortOnHost(port)
%
%   Inputs:
%       port - nonnegative integer. UART index (0-based).
%
%   Outputs:
%       none
%
%   Example:
%       validateUartPortOnHost(0);
%
%   Other m-files required: arduinopio.boards.getBoard
%   Subfunctions: none
%   MAT-files required: none
%
%   See also: VALIDATEUARTPORT, GETBOARD

%   Author: Frey, Jed
%   28-Sep-2026; Last revision: 28-Sep-2026

%------------- BEGIN CODE --------------
    info = arduinopio.boards.getBoard();
    if port >= info.UartCount
        error("arduinopio:InvalidUart", ...
            "%s has %d UART(s). Port must be in 0:%d.", ...
            info.DisplayName, info.UartCount, info.UartCount-1);
    end
end
