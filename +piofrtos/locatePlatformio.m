function pioCmd = locatePlatformio(options)
%LOCATEPLATFORMIO - Return the host PlatformIO CLI path.
%   Resolves the pio executable for the piofrtos Simulink target makefile
%   (pio_cmd.mk) and related hooks. Order: PIO_CMD environment variable when
%   it names an existing file; then PATH via where/command -v; then default
%   ~/.platformio/penv install locations. Paths are normalized to forward
%   slashes. When not found and MustExist is false, returns "". When MustExist
%   is true and nothing is found, errors with piofrtos:PlatformIONotFound.
%
%   Syntax:
%       pioCmd = piofrtos.locatePlatformio()
%       pioCmd = piofrtos.locatePlatformio(MustExist=false)
%       pioCmd = piofrtos.locatePlatformio(MustExist=true)
%
%   Inputs:
%       options.MustExist - (1,1) logical. Default: false. If true, raise
%           piofrtos:PlatformIONotFound when PlatformIO cannot be located.
%
%   Outputs:
%       pioCmd - string absolute or PATH-resolved path to pio, or "" if missing
%           and MustExist is false.
%
%   Example:
%       % Prefer a soft lookup for makefile generation.
%       pioCmd = piofrtos.locatePlatformio(MustExist=false);
%
%   Other m-files required: none
%   Subfunctions: findOnPath, findDefaultInstall, normalizePioPath
%   MAT-files required: none
%
%   See also: WRITEGENERATEDFILES, GENERATETARGETFILES

%   Author: Frey, Jed
%   28-Sep-2026; Last revision: 28-Sep-2026

%------------- BEGIN CODE --------------
    arguments
        options.MustExist (1,1) logical = false
    end

    pioCmd = string(getenv("PIO_CMD"));
    if strlength(pioCmd) > 0 && isfile(pioCmd)
        pioCmd = normalizePioPath(pioCmd);
        return
    end

    pioCmd = findOnPath();
    if strlength(pioCmd) == 0
        pioCmd = findDefaultInstall();
    end

    if strlength(pioCmd) == 0 && options.MustExist
        error("piofrtos:PlatformIONotFound", ...
            "PlatformIO CLI (pio) was not found. Install PlatformIO Core " + ...
            "and ensure pio is on PATH, or set the PIO_CMD environment variable.");
    end
end

function pioCmd = findOnPath()
%FINDONPATH - Locate pio using the system PATH.
%   Local helper for locatePlatformio. On Windows runs "where pio 2>nul";
%   elsewhere runs "command -v pio". Returns the first non-empty line as a
%   normalized path, or "" when the command fails.
%
%   Syntax:
%       pioCmd = findOnPath()
%
%   Inputs:
%       none
%
%   Outputs:
%       pioCmd - string path to pio, or "".
%
%   Example:
%       pioCmd = findOnPath();
%
%   See also: LOCATEPLATFORMIO, FINDDEFAULTINSTALL
    pioCmd = "";
    if ispc
        [status, cmdOutput] = system("where pio 2>nul");
    else
        [status, cmdOutput] = system("command -v pio");
    end

    if status ~= 0
        return
    end

    lines = splitlines(string(cmdOutput));
    lines = strip(lines);
    lines = lines(strlength(lines) > 0);
    if ~isempty(lines)
        pioCmd = normalizePioPath(lines(1));
    end
end

function pioCmd = findDefaultInstall()
%FINDDEFAULTINSTALL - Locate pio under the default PlatformIO Core install.
%   Local helper for locatePlatformio. Checks USERPROFILE or HOME for
%   .platformio/penv Scripts/pio.exe, Scripts/pio, and bin/pio.
%
%   Syntax:
%       pioCmd = findDefaultInstall()
%
%   Inputs:
%       none
%
%   Outputs:
%       pioCmd - string path to the first existing candidate, or "".
%
%   Example:
%       pioCmd = findDefaultInstall();
%
%   See also: LOCATEPLATFORMIO, FINDONPATH
    pioCmd = "";
    homeFolder = string(getenv("USERPROFILE"));
    if strlength(homeFolder) == 0
        homeFolder = string(getenv("HOME"));
    end

    candidateList = [
        fullfile(homeFolder, ".platformio", "penv", "Scripts", "pio.exe")
        fullfile(homeFolder, ".platformio", "penv", "Scripts", "pio")
        fullfile(homeFolder, ".platformio", "penv", "bin", "pio")
        ];

    for candidateIndex = 1:numel(candidateList)
        if isfile(candidateList(candidateIndex))
            pioCmd = normalizePioPath(candidateList(candidateIndex));
            return
        end
    end
end

function pioCmd = normalizePioPath(pioCmd)
%NORMALIZEPIOPATH - Convert a pio path to forward-slash form.
%   Local helper for locatePlatformio and its finders. Ensures makefile and
%   cross-platform string handling use consistent separators.
%
%   Syntax:
%       pioCmd = normalizePioPath(pioCmd)
%
%   Inputs:
%       pioCmd - path string that may contain backslashes.
%
%   Outputs:
%       pioCmd - string with "\" replaced by "/".
%
%   Example:
%       pioCmd = normalizePioPath("C:\Users\me\.platformio\penv\Scripts\pio.exe");
%
%   See also: LOCATEPLATFORMIO
    pioCmd = replace(string(pioCmd), "\", "/");
end
