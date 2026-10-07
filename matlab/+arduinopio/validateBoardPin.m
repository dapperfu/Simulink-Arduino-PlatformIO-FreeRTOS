function validateBoardPin(boardId, pin, kind)
%VALIDATEBOARDPIN - Error if PIN is not valid for KIND on a named board.
%   Board maps are MATLAB-only. Code generation skips the host lookup via
%   coder.target("MATLAB") and validateBoardPinOnHost. Package path:
%   arduinopio.validateBoardPin.
%
%   Syntax:
%       arduinopio.validateBoardPin(boardId, pin, kind)
%
%   Inputs:
%       boardId - (1,1) string. Board id passed to arduinopio.boards.getBoard.
%       pin - (1,1) integer. Pin, UART port, or CAN controller index.
%       kind - text. digital, analog, pwm, dac, touch, uart, or can.
%
%   Outputs:
%       none
%
%   Example:
%       arduinopio.validateBoardPin("due", 66, "dac");
%
%   Other m-files required: validateBoardPinOnHost (private)
%   Subfunctions: none
%   MAT-files required: none
%
%   See also: VALIDATEPIN, GETBOARD

%   Author: Frey, Jed
%   07-Oct-2026; Last revision: 07-Oct-2026

%------------- BEGIN CODE --------------
    arguments
        boardId (1,1) string
        pin (1,1) {mustBeNumeric, mustBeInteger, mustBeNonnegative}
        kind {mustBeTextScalar, mustBeMember(kind, {'digital', 'analog', 'pwm', 'dac', 'touch', 'uart', 'can'})}
    end

    coder.extrinsic("validateBoardPinOnHost");
    if coder.target("MATLAB")
        validateBoardPinOnHost(boardId, pin, kind);
    end
end
