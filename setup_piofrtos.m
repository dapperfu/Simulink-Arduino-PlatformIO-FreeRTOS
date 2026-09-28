function setup_piofrtos()
%SETUP_PIOFRTOS - Add the PlatformIO FreeRTOS target to the MATLAB path.
%   Adds the repository root and piofrtos/ folder. If setupArduinoPioPath.m
%   exists, calls it; otherwise adds examples/ only. Regenerates target files
%   via piofrtos.generateTargetFiles, refreshes Simulink customizations, and
%   prints instructions to select system target file piofrtos.tlc.
%
%   Syntax:
%       setup_piofrtos()
%
%   Inputs:
%       none
%
%   Outputs:
%       none
%
%   Example:
%       setup_piofrtos();
%
%   Other m-files required: setupArduinoPioPath, piofrtos.generateTargetFiles
%   Subfunctions: none
%   MAT-files required: none
%
%   See also: SETUPARDUINOPIOPATH, PIOFRTOS_MAKE_RTW_HOOK, BUILD_ALL

%   Author: Frey, Jed
%   28-Sep-2026; Last revision: 28-Sep-2026

%------------- BEGIN CODE --------------

    rootFolder = fileparts(mfilename("fullpath"));
    addpath(rootFolder);
    addpath(fullfile(rootFolder, "piofrtos"));

    if isfile(fullfile(rootFolder, "setupArduinoPioPath.m"))
        setupArduinoPioPath();
    else
        addpath(fullfile(rootFolder, "examples"));
    end

    piofrtos.generateTargetFiles();
    sl_refresh_customizations();

    fprintf("Arduino FreeRTOS (PlatformIO) target is ready.\n");
    fprintf("Select system target file piofrtos.tlc in Code Generation settings.\n");
end
