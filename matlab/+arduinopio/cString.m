function txt = cString(value, maxLen)
%CSTRING - Build a fixed-length null-terminated char row for coder.ceval.
%   Copies VALUE into a char row of length maxLen+1 and writes a trailing NUL.
%   Extra characters are truncated. VALUE is a char row or string; codegen
%   passes char. Package path: arduinopio.cString.
%
%   Syntax:
%       txt = arduinopio.cString(value, maxLen)
%
%   Inputs:
%       value - char row or string. Text to pass to generated C code.
%       maxLen - (1,1) positive integer. Maximum characters before the NUL.
%
%   Outputs:
%       txt - char row of length maxLen+1, null-terminated.
%
%   Example:
%       txt = arduinopio.cString("sensor", 32);
%
%   Other m-files required: none
%   Subfunctions: none
%   MAT-files required: none
%
%   See also: WIFITRANSMIT, BLETRANSMIT

%   Author: Frey, Jed
%   07-Oct-2026; Last revision: 07-Oct-2026

%------------- BEGIN CODE --------------
    arguments
        value {mustBeTextScalar}
        maxLen (1,1) double {mustBeInteger, mustBePositive}
    end

    txt = char(zeros(1, maxLen + 1));
    raw = char(value);
    count = min(numel(raw), maxLen);
    if count > 0
        txt(1:count) = raw(1:count);
    end
end
