function pioCmd = locatePlatformio(options)
%locatePlatformio Return the host PlatformIO CLI path.
%   pioCmd = piofrtos.locatePlatformio() searches PATH and the default
%   PlatformIO install locations. Returns "" when PlatformIO is not found
%   unless MustExist is true.
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
    pioCmd = replace(string(pioCmd), "\", "/");
end
