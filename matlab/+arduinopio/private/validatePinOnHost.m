function validatePinOnHost(pin, kind)
%validatePinOnHost MATLAB-only pin check against the active board map.

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
