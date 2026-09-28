function validateEepromRange(startAddress, dataLength)
%VALIDATEEEPROMRANGE - Error if an EEPROM access is outside the active board map.
%   Board maps are MATLAB-only; code generation skips the host lookup via
%   coder.target("MATLAB") and validateEepromRangeOnHost. Package path:
%   arduinopio.validateEepromRange.
%
%   Syntax:
%       arduinopio.validateEepromRange(startAddress, dataLength)
%
%   Inputs:
%       startAddress - (1,1) nonnegative integer. First EEPROM address.
%       dataLength - (1,1) positive integer. Byte count of the access.
%
%   Outputs:
%       none
%
%   Example:
%       arduinopio.validateEepromRange(0, 16);
%
%   Other m-files required: validateEepromRangeOnHost (private)
%   Subfunctions: none
%   MAT-files required: none
%
%   See also: VALIDATEEEPROMRANGEONHOST, GETBOARD

%   Author: Frey, Jed
%   28-Sep-2026; Last revision: 28-Sep-2026

%------------- BEGIN CODE --------------
    arguments
        startAddress (1,1) {mustBeNumeric, mustBeInteger, mustBeNonnegative}
        dataLength (1,1) {mustBeNumeric, mustBeInteger, mustBePositive}
    end

    coder.extrinsic("validateEepromRangeOnHost");
    if coder.target("MATLAB")
        validateEepromRangeOnHost(startAddress, dataLength);
    end
end
