function deps = knownLibDeps()
%KNOWNLIBDEPS - Return PlatformIO lib_deps keyed by codegen preprocessor defines.
%   Struct array maps Define names to LibDep strings used when emitting
%   platformio.ini dependencies. Package path: arduinopio.knownLibDeps.
%
%   Syntax:
%       deps = arduinopio.knownLibDeps()
%
%   Inputs:
%       none
%
%   Outputs:
%       deps - struct array with fields:
%           Define - "ARDUINOPIO_NEED_SERVO", "ARDUINOPIO_NEED_MCP2515";
%           LibDep - "Servo", "autowp/autowp-mcp2515".
%
%   Example:
%       deps = arduinopio.knownLibDeps();
%
%   Other m-files required: none
%   Subfunctions: none
%   MAT-files required: none
%
%   See also: ADDLIBDEP, UPDATEDRIVERBUILDINFO

%   Author: Frey, Jed
%   28-Sep-2026; Last revision: 28-Sep-2026

%------------- BEGIN CODE --------------
    deps = struct( ...
        "Define", {"ARDUINOPIO_NEED_SERVO", "ARDUINOPIO_NEED_MCP2515"}, ...
        "LibDep", {"Servo", "autowp/autowp-mcp2515"});
end
