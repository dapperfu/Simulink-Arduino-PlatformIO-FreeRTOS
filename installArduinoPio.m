function installArduinoPio()
%installArduinoPio Put the toolbox on the path, build S-functions if possible, and create the library.

    setupArduinoPioPath();
    try
        buildArduinoPioSFunctions();
    catch exception
        warning("arduinopio:MexSkipped", ...
            "S-function mex build skipped (%s). Interrupt blocks use MATLAB System objects instead.", ...
            exception.message);
    end
    createArduinoPioLibrary();
    createArduinoPioExamples();
    setupArduinoPioPath();
    sl_refresh_customizations();
end
