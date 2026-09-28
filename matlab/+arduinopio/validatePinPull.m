function validatePinPull(pinPull)
%VALIDATEPINPULL - Error if PINPULL is not valid for the active board.
%   Board maps are MATLAB-only; code generation skips the host lookup via
%   coder.target("MATLAB") and validatePinPullOnHost. Package path:
%   arduinopio.validatePinPull.
%
%   Syntax:
%       arduinopio.validatePinPull(pinPull)
%
%   Inputs:
%       pinPull - resistor option accepted by pinPullIndex (numeric or name).
%
%   Outputs:
%       none
%
%   Example:
%       arduinopio.validatePinPull("None");
%
%   Other m-files required: validatePinPullOnHost (private)
%   Subfunctions: none
%   MAT-files required: none
%
%   See also: VALIDATEPINPULLONHOST, PINPULLINDEX, PINPULLNAMES

%   Author: Frey, Jed
%   28-Sep-2026; Last revision: 28-Sep-2026

%------------- BEGIN CODE --------------
    coder.extrinsic("validatePinPullOnHost");
    if coder.target("MATLAB")
        validatePinPullOnHost(pinPull);
    end
end
