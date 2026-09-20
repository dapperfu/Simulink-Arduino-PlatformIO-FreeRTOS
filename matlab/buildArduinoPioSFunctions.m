function buildArduinoPioSFunctions()
%buildArduinoPioSFunctions Compile the interrupt S-functions for simulation.

    rootDir = arduinopio.getRootFolder();
    sfcnDir = fullfile(rootDir, "sfcn");
    mex(fullfile(sfcnDir, "arduinopio_extint.c"), "-outdir", sfcnDir);
    mex(fullfile(sfcnDir, "arduinopio_hwint_avr.c"), "-outdir", sfcnDir);
end
