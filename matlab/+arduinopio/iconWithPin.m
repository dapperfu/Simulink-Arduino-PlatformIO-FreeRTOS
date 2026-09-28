function lines = iconWithPin(title, pin, options)
%ICONWITHPIN - Build MATLAB System block icon text lines that include pin numbers.
%   Returns a two-element string column: the title, then a label and pin text.
%   Multiple pin values are joined with commas. If more than one pin is given and
%   the label is still "Pin", the label becomes "Pins". Package path:
%   arduinopio.iconWithPin.
%
%   Syntax:
%       lines = arduinopio.iconWithPin(title, pin)
%       lines = arduinopio.iconWithPin(title, pin, Label=label)
%
%   Inputs:
%       title - (1,1) string. First icon line (block name or short title).
%       pin - numeric. Scalar or vector of pin numbers shown on the second line.
%       options.Label - (1,1) string. Prefix before the pin text. Default: "Pin".
%
%   Outputs:
%       lines - string column vector. [title; label + " " + pinText].
%
%   Example:
%       lines = arduinopio.iconWithPin("PWM", 9);
%
%   Other m-files required: none
%   Subfunctions: none
%   MAT-files required: none
%
%   See also: MASKDISPLAYWITHPIN

%   Author: Frey, Jed
%   28-Sep-2026; Last revision: 28-Sep-2026

%------------- BEGIN CODE --------------
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
