function validateUartPort(port)
%VALIDATEUARTPORT - Error if PORT is not a valid UART index on the active board.
%   Board maps are MATLAB-only; code generation skips the host lookup via
%   coder.target("MATLAB") and validateUartPortOnHost. Package path:
%   arduinopio.validateUartPort.
%
%   Syntax:
%       arduinopio.validateUartPort(port)
%
%   Inputs:
%       port - (1,1) nonnegative integer. UART port index (0-based).
%
%   Outputs:
%       none
%
%   Example:
%       arduinopio.validateUartPort(0);
%
%   Other m-files required: validateUartPortOnHost (private)
%   Subfunctions: none
%   MAT-files required: none
%
%   See also: VALIDATEUARTPORTONHOST, GETBOARD

%   Author: Frey, Jed
%   28-Sep-2026; Last revision: 28-Sep-2026

%------------- BEGIN CODE --------------
    arguments
        port (1,1) {mustBeNumeric, mustBeInteger, mustBeNonnegative}
    end

    coder.extrinsic("validateUartPortOnHost");
    if coder.target("MATLAB")
        validateUartPortOnHost(port);
    end
end
