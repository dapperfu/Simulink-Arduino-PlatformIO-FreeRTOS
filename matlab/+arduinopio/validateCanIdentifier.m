function validateCanIdentifier(identifier, isExtended, propertyName)
%VALIDATECANIDENTIFIER - Error if IDENTIFIER does not fit a CAN 2.0 frame type.
%   Standard frames allow 0-2047; extended frames allow 0-536870911. Errors
%   arduinopio:CanId with propertyName when identifier exceeds the max for the
%   frame type. Package path: arduinopio.validateCanIdentifier.
%
%   Syntax:
%       arduinopio.validateCanIdentifier(identifier, isExtended, propertyName)
%
%   Inputs:
%       identifier - (1,1) nonnegative integer. CAN identifier to check.
%       isExtended - (1,1) logical. True for 29-bit extended frames.
%       propertyName - (1,1) string. Name used in the error message.
%
%   Outputs:
%       none
%
%   Example:
%       arduinopio.validateCanIdentifier(0x100, false, "Identifier");
%
%   Other m-files required: none
%   Subfunctions: none
%   MAT-files required: none
%
%   See also: VALIDATEPIN, VALIDATEUARTPORT

%   Author: Frey, Jed
%   28-Sep-2026; Last revision: 28-Sep-2026

%------------- BEGIN CODE --------------
    arguments
        identifier (1,1) {mustBeNumeric, mustBeInteger, mustBeNonnegative}
        isExtended (1,1) logical
        propertyName (1,1) string
    end

    maxStandardId = 2047;
    maxExtendedId = 536870911;
    if isExtended
        maxId = maxExtendedId;
    else
        maxId = maxStandardId;
    end

    if identifier > maxId
        error("arduinopio:CanId", ...
            "%s %d is too large. Use 0-%d for this frame type.", ...
            propertyName, identifier, maxId);
    end
end
