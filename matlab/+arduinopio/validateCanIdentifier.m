function validateCanIdentifier(identifier, isExtended, propertyName)
%validateCanIdentifier Error if IDENTIFIER does not fit a CAN 2.0 frame type.

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
