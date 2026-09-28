function names = pinPullNames()
%PINPULLNAMES - Display names for Arduino input resistor options.
%   Returns the ordered labels corresponding to pinPullIndex values 0, 1, and 2.
%   Package path: arduinopio.pinPullNames.
%
%   Syntax:
%       names = arduinopio.pinPullNames()
%
%   Inputs:
%       none
%
%   Outputs:
%       names - 1-by-3 string. ["None", "Pull-up", "Pull-down"].
%
%   Example:
%       names = arduinopio.pinPullNames();
%
%   Other m-files required: none
%   Subfunctions: none
%   MAT-files required: none
%
%   See also: PINPULLINDEX, VALIDATEPINPULL

%   Author: Frey, Jed
%   28-Sep-2026; Last revision: 28-Sep-2026

%------------- BEGIN CODE --------------
    names = ["None", "Pull-up", "Pull-down"];
end
