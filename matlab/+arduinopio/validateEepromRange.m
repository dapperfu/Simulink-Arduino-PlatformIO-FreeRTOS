function validateEepromRange(startAddress, dataLength)
%validateEepromRange Error if an EEPROM access is outside the active board map.
%   Board maps are MATLAB-only; code generation skips the host lookup.

    arguments
        startAddress (1,1) {mustBeNumeric, mustBeInteger, mustBeNonnegative}
        dataLength (1,1) {mustBeNumeric, mustBeInteger, mustBePositive}
    end

    coder.extrinsic("validateEepromRangeOnHost");
    if coder.target("MATLAB")
        validateEepromRangeOnHost(startAddress, dataLength);
    end
end
