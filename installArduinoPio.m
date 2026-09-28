function installArduinoPio()
%INSTALLARDUINOPIO - Install path, mex S-functions, library, and examples.
%   Calls setupArduinoPioPath, attempts buildArduinoPioSFunctions (warns and
%   continues if mex fails), then createArduinoPioLibrary and
%   createArduinoPioExamples. Re-runs setupArduinoPioPath and
%   sl_refresh_customizations so the Library Browser picks up arduinopio_lib.
%
%   Syntax:
%       installArduinoPio()
%
%   Inputs:
%       none
%
%   Outputs:
%       none
%
%   Example:
%       installArduinoPio();
%
%   Other m-files required: setupArduinoPioPath, buildArduinoPioSFunctions,
%       createArduinoPioLibrary, createArduinoPioExamples
%   Subfunctions: none
%   MAT-files required: none
%
%   See also: SETUPARDUINOPIOPATH, CREATEARDUINOPIOLIBRARY, BUILD_ALL

%   Author: Frey, Jed
%   28-Sep-2026; Last revision: 28-Sep-2026

%------------- BEGIN CODE --------------

    setupArduinoPioPath();
    try
        buildArduinoPioSFunctions();
    catch exception
        warning("arduinopio:MexSkipped", ...
            "C S-function mex build skipped (%s). Interrupt and Level-2 C Digital IO blocks need mex files for simulation.", ...
            exception.message);
    end
    createArduinoPioLibrary();
    createArduinoPioExamples();
    setupArduinoPioPath();
    sl_refresh_customizations();
end
