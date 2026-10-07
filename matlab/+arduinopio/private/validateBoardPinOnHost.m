function validateBoardPinOnHost(boardId, pin, kind)
%VALIDATEBOARDPINONHOST - Error if PIN is not allowed for KIND on BOARDID.
%   MATLAB-only. Reads the named board map and errors arduinopio:InvalidPin
%   when the pin, UART port, DAC pin, touch pin, or CAN controller is outside
%   that map. Private; called from validateBoardPin via coder.extrinsic.
%
%   Syntax:
%       validateBoardPinOnHost(boardId, pin, kind)
%
%   Inputs:
%       boardId - string. Board id for arduinopio.boards.getBoard.
%       pin - integer. Pin or controller index to validate.
%       kind - text. digital, analog, pwm, dac, touch, uart, or can.
%
%   Outputs:
%       none
%
%   Example:
%       validateBoardPinOnHost("mega2560", 54, "digital");
%
%   Other m-files required: arduinopio.boards.getBoard
%   Subfunctions: allowedValues, formatPins
%   MAT-files required: none
%
%   See also: VALIDATEBOARDPIN, GETBOARD

%   Author: Frey, Jed
%   07-Oct-2026; Last revision: 07-Oct-2026

%------------- BEGIN CODE --------------
    kindName = string(kind);
    info = arduinopio.boards.getBoard(string(boardId));
    allowed = allowedValues(info, kindName);
    if ~ismember(double(pin), double(allowed))
        error("arduinopio:InvalidPin", ...
            "Pin %d is not a valid %s pin on %s. Use one of: %s.", ...
            pin, kindName, info.DisplayName, formatPins(allowed));
    end
end

function allowed = allowedValues(info, kindName)
%ALLOWEDVALUES - Select the pin or index vector for KIND from a board map.
    switch kindName
        case "digital"
            allowed = info.DigitalPins;
        case "analog"
            allowed = info.AnalogPins;
        case "pwm"
            allowed = info.PwmPins;
        case "dac"
            allowed = featurePins(info, "DacPins");
        case "touch"
            allowed = featurePins(info, "TouchPins");
        case "uart"
            allowed = 0:max(info.UartCount - 1, 0);
        case "can"
            count = 0;
            if isfield(info, "CanControllerCount")
                count = info.CanControllerCount;
            end
            allowed = 0:max(count - 1, 0);
            if count <= 0
                allowed = double.empty(1, 0);
            end
        otherwise
            allowed = double.empty(1, 0);
    end
end

function pins = featurePins(info, fieldName)
%FEATUREPINS - Return a numeric pin vector, or empty when the field is absent.
    if isfield(info, fieldName)
        pins = info.(fieldName);
    else
        pins = double.empty(1, 0);
    end
end

function text = formatPins(pins)
%FORMATPINS - Render an allowed-pin vector for an error message.
    if isempty(pins)
        text = "(none)";
    else
        text = mat2str(pins);
    end
end
