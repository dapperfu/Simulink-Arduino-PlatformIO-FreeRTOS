function setupArduinoPioPath()
%SETUPARDUINOPIOPATH - Add Arduino PIO FreeRTOS folders to the MATLAB path.
%   Resolves the toolbox root from this file location and addpath the root,
%   matlab/, and any existing libraries/, sfcn/, and examples/ folders. Call
%   once per MATLAB session before opening the library or examples.
%
%   Syntax:
%       setupArduinoPioPath()
%
%   Inputs:
%       none
%
%   Outputs:
%       none
%
%   Example:
%       setupArduinoPioPath();
%
%   Other m-files required: none
%   Subfunctions: addExistingPath
%   MAT-files required: none
%
%   See also: SETUP_PIOFRTOS, INSTALLARDUINOPIO, SLBLOCKS

%   Author: Frey, Jed
%   28-Sep-2026; Last revision: 28-Sep-2026

%------------- BEGIN CODE --------------

    rootDir = fileparts(mfilename("fullpath"));
    addpath(rootDir);
    addpath(fullfile(rootDir, "matlab"));
    addExistingPath(fullfile(rootDir, "libraries"));
    addExistingPath(fullfile(rootDir, "sfcn"));
    addExistingPath(fullfile(rootDir, "examples"));
end

function addExistingPath(folderName)
%ADDEXISTINGPATH - addpath a folder only when it already exists.
%   Checks isfolder(folderName) and calls addpath when true so missing optional
%   directories (libraries, sfcn, examples) do not error during path setup.
%
%   Syntax:
%       addExistingPath(folderName)
%
%   Inputs:
%       folderName - Absolute or relative folder path
%
%   Outputs:
%       none
%
%   Example:
%       addExistingPath(fullfile(rootDir, "sfcn"));
%
%   See also: SETUPARDUINOPIOPATH

    if isfolder(folderName)
        addpath(folderName);
    end
end
