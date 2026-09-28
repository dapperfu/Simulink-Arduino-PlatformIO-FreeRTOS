function lines = iconWithPin(title, pin, options)
%iconWithPin MATLAB System block icon lines that include a pin number.
    arguments
        title (1,1) string
        pin {mustBeNumeric}
        options.Label (1,1) string = "Pin"
    end

    pinText = join(string(pin(:)), ", ");
    label = options.Label;
    if numel(pin) > 1 && label == "Pin"
        label = "Pins";
    end
    lines = [title; label + " " + pinText];
end
