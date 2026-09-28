function validateEepromRangeOnHost(startAddress, dataLength)
%validateEepromRangeOnHost MATLAB-only EEPROM range check against the active board.

    info = arduinopio.boards.getBoard();
    lastAddress = startAddress + dataLength - 1;
    if lastAddress >= info.EepromSize
        error("arduinopio:EepromRange", ...
            "EEPROM access [%d:%d] exceeds %s size %d. Use a start address and length that fit.", ...
            startAddress, lastAddress, info.DisplayName, info.EepromSize);
    end
end
