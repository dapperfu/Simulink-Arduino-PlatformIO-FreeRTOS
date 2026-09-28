function warnIfNotLibraryOnHost(warningId, messageText)
%WARNIFNOTLIBRARYONHOST - Issue a warning unless the current diagram is a library.
%   MATLAB-only helper. Returns silently when bdroot BlockDiagramType is
%   "library". Otherwise calls warning(warningId, "%s", messageText). Private
%   folder; invoked via coder.extrinsic from warnIfNotLibrary.
%
%   Syntax:
%       warnIfNotLibraryOnHost(warningId, messageText)
%
%   Inputs:
%       warningId - warning identifier string (e.g. "arduinopio:Timer1Conflict").
%       messageText - warning message text passed to warning as %s.
%
%   Outputs:
%       none
%
%   Example:
%       warnIfNotLibraryOnHost("arduinopio:Timer1Conflict", "Timer1 shared.");
%
%   Other m-files required: none
%   Subfunctions: none
%   MAT-files required: none
%
%   See also: WARNIFNOTLIBRARY

%   Author: Frey, Jed
%   28-Sep-2026; Last revision: 28-Sep-2026

%------------- BEGIN CODE --------------
    try
        if string(get_param(bdroot, "BlockDiagramType")) == "library"
            return
        end
    catch
        % No diagram is loaded. Continue and warn.
    end
    warning(warningId, "%s", messageText);
end
