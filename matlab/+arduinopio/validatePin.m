function validatePin(pin, kind)
%VALIDATEPIN - Error if PIN is not valid for KIND on the active board.
%   KIND is "digital", "analog", "pwm", "interrupt", or "capture". Board maps
%   are MATLAB-only; code generation skips the host lookup via
%   coder.target("MATLAB") and validatePinOnHost. Package path:
%   arduinopio.validatePin.
%
%   Syntax:
%       arduinopio.validatePin(pin, kind)
%
%   Inputs:
%       pin - (1,1) integer. Pin number to validate.
%       kind - text scalar member of digital|analog|pwm|interrupt|capture.
%
%   Outputs:
%       none
%
%   Example:
%       arduinopio.validatePin(9, "pwm");
%
%   Other m-files required: validatePinOnHost (private)
%   Subfunctions: none
%   MAT-files required: none
%
%   See also: VALIDATEPINONHOST, GETBOARD

%   Author: Frey, Jed
%   28-Sep-2026; Last revision: 28-Sep-2026

%------------- BEGIN CODE --------------
    arguments
        pin (1,1) {mustBeNumeric, mustBeInteger}
        kind {mustBeTextScalar, mustBeMember(kind, {'digital', 'analog', 'pwm', 'interrupt', 'capture'})}
    end

    coder.extrinsic("validatePinOnHost");
    if coder.target("MATLAB")
        validatePinOnHost(pin, kind);
    end
end
