function buildArduinoPioSFunctions()
%buildArduinoPioSFunctions Compile C S-functions needed for simulation.
    rootDir = arduinopio.getRootFolder();
    sfcnDir = fullfile(rootDir, "sfcn");
    sourceFiles = [
        "arduinopio_extint.c"
        "arduinopio_hwint_avr.c"
        "arduinopio_digital_input_c.c"
        "arduinopio_digital_output_c.c"
        ];

    for fileIndex = 1:numel(sourceFiles)
        mex(fullfile(sfcnDir, sourceFiles(fileIndex)), "-outdir", sfcnDir);
    end
end
