function warnIfNotLibrary(warningId, messageText)
%WARNIFNOTLIBRARY - Issue a warning unless the current diagram is a library.
%   Diagram queries are MATLAB-only; code generation skips the warning via
%   coder.target("MATLAB") and the private extrinsic warnIfNotLibraryOnHost.
%   Package path: arduinopio.warnIfNotLibrary.
%
%   Syntax:
%       arduinopio.warnIfNotLibrary(warningId, messageText)
%
%   Inputs:
%       warningId - (1,1) string. Warning identifier.
%       messageText - (1,1) string. Warning message body.
%
%   Outputs:
%       none
%
%   Example:
%       arduinopio.warnIfNotLibrary("arduinopio:Timer1Conflict", "Timer1 shared.");
%
%   Other m-files required: warnIfNotLibraryOnHost (private)
%   Subfunctions: none
%   MAT-files required: none
%
%   See also: WARNTIMERCONFLICT, WARNIFNOTLIBRARYONHOST

%   Author: Frey, Jed
%   28-Sep-2026; Last revision: 28-Sep-2026

%------------- BEGIN CODE --------------
    arguments
        warningId (1,1) string
        messageText (1,1) string
    end

    coder.extrinsic("warnIfNotLibraryOnHost");
    if coder.target("MATLAB")
        warnIfNotLibraryOnHost(warningId, messageText);
    end
end
