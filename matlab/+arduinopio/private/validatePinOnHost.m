function validatePinOnHost(pin, kind)
%VALIDATEPINONHOST - Error if PIN is not allowed for KIND on the active board.
%   MATLAB-only. Selects DigitalPins, AnalogPins, PwmPins, InterruptPins, or
%   CapturePins from getBoard() and errors arduinopio:InvalidPin when pin is
%   not a member. Private; called from validatePin via coder.extrinsic.
%
%   Syntax:
%       validatePinOnHost(pin, kind)
%
%   Inputs:
%       pin - integer. Pin number to validate.
%       kind - text. One of "digital", "analog", "pwm", "interrupt", "capture".
%
%   Outputs:
%       none
%
%   Example:
%       validatePinOnHost(13, "digital");
%
%   Other m-files required: arduinopio.boards.getBoard
%   Subfunctions: none
%   MAT-files required: none
%
%   See also: VALIDATEPIN, GETBOARD

%   Author: Frey, Jed
%   28-Sep-2026; Last revision: 28-Sep-2026

%------------- BEGIN CODE --------------
    kindName = string(kind);
    info = arduinopio.boards.getBoard();
    switch kindName
        case "digital"
            allowedPins = info.DigitalPins;
        case "analog"
            allowedPins = info.AnalogPins;
        case "pwm"
            allowedPins = info.PwmPins;
        case "interrupt"
            allowedPins = info.InterruptPins;
        case "capture"
            allowedPins = info.CapturePins;
        otherwise
            % mustBeMember already restricts kind.
            allowedPins = [];
    end

    if ~ismember(pin, allowedPins)
        error("arduinopio:InvalidPin", ...
            "Pin %d is not a valid %s pin on %s. Use one of: %s.", ...
            pin, kindName, info.DisplayName, mat2str(allowedPins));
    end
end
