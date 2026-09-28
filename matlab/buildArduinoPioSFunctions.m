function buildArduinoPioSFunctions()
%BUILDARDUINOPIOSFUNCTIONS - Compile C S-functions needed for host simulation.
%   Runs mex on each C source under sfcn/ for external interrupt, AVR hardware
%   interrupt, and Level-2 C digital input/output S-functions. Output mex files
%   are written to the same sfcn folder via -outdir so Library Browser blocks
%   that use those FunctionName values can simulate on the host.
%
%   Syntax:
%       buildArduinoPioSFunctions()
%
%   Inputs:
%       none
%
%   Outputs:
%       none
%
%   Example:
%       buildArduinoPioSFunctions();
%
%   Other m-files required: arduinopio.getRootFolder
%   Subfunctions: none
%   MAT-files required: none
%
%   See also: INSTALLARDUINOPIO, CREATEARDUINOPIOLIBRARY, RTWMAKECFG

%   Author: Frey, Jed
%   28-Sep-2026; Last revision: 28-Sep-2026

%------------- BEGIN CODE --------------

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
