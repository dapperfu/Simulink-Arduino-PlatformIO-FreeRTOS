function setup_piofrtos()
%setup_piofrtos Add the Arduino FreeRTOS PlatformIO target to the MATLAB path.
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
