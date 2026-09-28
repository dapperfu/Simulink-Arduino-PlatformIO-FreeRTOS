function index = pinPullIndex(pinPull)
%pinPullIndex Map a resistor option to 0=None, 1=Pull-up, 2=Pull-down.

    arguments
        pinPull
    end

    if isnumeric(pinPull)
        if ~(isscalar(pinPull) && isfinite(pinPull) && ismember(pinPull, 0:2))
            error("arduinopio:InvalidPinPull", ...
                "Internal resistor must be 0 (None), 1 (Pull-up), or 2 (Pull-down).");
        end
        index = double(pinPull);
        return
    end

    name = char(pinPull);
    if strcmp(name, "None")
        index = 0;
    elseif strcmp(name, "Pull-up")
        index = 1;
    elseif strcmp(name, "Pull-down")
        index = 2;
    else
        error("arduinopio:InvalidPinPull", ...
            "Internal resistor must be one of: None, Pull-up, Pull-down.");
    end
end
