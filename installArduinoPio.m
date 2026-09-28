function installArduinoPio()
%installArduinoPio Put the toolbox on the path, build S-functions if possible, and create the library.

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
