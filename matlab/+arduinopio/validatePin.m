function validatePin(pin, kind)
%validatePin Error if PIN is not valid for KIND on the active board.
%   KIND is "digital", "analog", "pwm", "interrupt", or "capture".

    arguments
        pin (1,1) {mustBeNumeric, mustBeInteger}
        kind (1,1) string {mustBeMember(kind, ["digital", "analog", "pwm", "interrupt", "capture"])}
    end

    info = arduinopio.boards.getBoard();
    switch kind
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
            pin, kind, info.DisplayName, mat2str(allowedPins));
    end
end
