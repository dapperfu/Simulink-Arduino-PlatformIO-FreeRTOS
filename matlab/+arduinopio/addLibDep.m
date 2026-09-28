function addLibDep(buildInfo, depName)
%ADDLIBDEP - Record a PlatformIO library dependency on the codegen build info.
%   Adds define ARDUINOPIO_NEED_<DEP> (uppercase depName) and a matching TMF
%   token |>DEFINE<| = "1" so the target can emit platformio.ini lib_deps.
%   Package path: arduinopio.addLibDep.
%
%   Syntax:
%       arduinopio.addLibDep(buildInfo, depName)
%
%   Inputs:
%       buildInfo - RTW.BuildInfo (or compatible) object.
%       depName - (1,1) string. Dependency name (e.g. "Servo", "MCP2515").
%
%   Outputs:
%       none
%
%   Example:
%       arduinopio.addLibDep(buildInfo, "Servo");
%
%   Other m-files required: none
%   Subfunctions: none
%   MAT-files required: none
%
%   See also: KNOWNLIBDEPS, UPDATEDRIVERBUILDINFO

%   Author: Frey, Jed
%   28-Sep-2026; Last revision: 28-Sep-2026

%------------- BEGIN CODE --------------
    arguments
        buildInfo
        depName (1,1) string
    end

    defineName = "ARDUINOPIO_NEED_" + upper(depName);
    addDefines(buildInfo, defineName);
    tokenName = "|>" + defineName + "<|";
    addTMFTokens(buildInfo, tokenName, "1");
end
