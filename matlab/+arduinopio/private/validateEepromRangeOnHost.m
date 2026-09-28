function validateEepromRangeOnHost(startAddress, dataLength)
%VALIDATEEEPROMRANGEONHOST - Error if an EEPROM span exceeds the active board size.
%   MATLAB-only. Uses getBoard() EepromSize and errors arduinopio:EepromRange
%   when startAddress+dataLength-1 is out of range. Private; called from
%   validateEepromRange via coder.extrinsic.
%
%   Syntax:
%       validateEepromRangeOnHost(startAddress, dataLength)
%
%   Inputs:
%       startAddress - nonnegative integer. First EEPROM address accessed.
%       dataLength - positive integer. Number of bytes in the access.
%
%   Outputs:
%       none
%
%   Example:
%       validateEepromRangeOnHost(0, 16);
%
%   Other m-files required: arduinopio.boards.getBoard
%   Subfunctions: none
%   MAT-files required: none
%
%   See also: VALIDATEEEPROMRANGE, GETBOARD

%   Author: Frey, Jed
%   28-Sep-2026; Last revision: 28-Sep-2026

%------------- BEGIN CODE --------------
    info = arduinopio.boards.getBoard();
    lastAddress = startAddress + dataLength - 1;
    if lastAddress >= info.EepromSize
        error("arduinopio:EepromRange", ...
            "EEPROM access [%d:%d] exceeds %s size %d. Use a start address and length that fit.", ...
            startAddress, lastAddress, info.DisplayName, info.EepromSize);
    end
end
