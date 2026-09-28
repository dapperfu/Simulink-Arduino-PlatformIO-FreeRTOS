function index = pinPullIndex(pinPull)
%PINPULLINDEX - Map a resistor option to 0=None, 1=Pull-up, 2=Pull-down.
%   Accepts numeric 0:2 or the display names from pinPullNames. Errors
%   arduinopio:InvalidPinPull for other values. Package path:
%   arduinopio.pinPullIndex.
%
%   Syntax:
%       index = arduinopio.pinPullIndex(pinPull)
%
%   Inputs:
%       pinPull - numeric scalar in 0:2, or text "None", "Pull-up", "Pull-down".
%
%   Outputs:
%       index - double. 0 for None, 1 for Pull-up, 2 for Pull-down.
%
%   Example:
%       idx = arduinopio.pinPullIndex("Pull-up");
%
%   Other m-files required: none
%   Subfunctions: none
%   MAT-files required: none
%
%   See also: PINPULLNAMES, VALIDATEPINPULL

%   Author: Frey, Jed
%   28-Sep-2026; Last revision: 28-Sep-2026

%------------- BEGIN CODE --------------
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
