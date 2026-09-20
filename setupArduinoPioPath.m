function setupArduinoPioPath()
%setupArduinoPioPath Add Arduino PIO FreeRTOS folders to the MATLAB path.
%   Call this once per MATLAB session before opening the library or examples.

    rootDir = fileparts(mfilename("fullpath"));
    addpath(rootDir);
    addpath(fullfile(rootDir, "matlab"));
    addExistingPath(fullfile(rootDir, "libraries"));
    addExistingPath(fullfile(rootDir, "sfcn"));
    addExistingPath(fullfile(rootDir, "examples"));
end

function addExistingPath(folderName)
    if isfolder(folderName)
        addpath(folderName);
    end
end
