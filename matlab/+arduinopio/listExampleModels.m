function modelNames = listExampleModels()
%LISTEXAMPLEMODELS - Return example model names that use the piofrtos.tlc target.
%   Provides the fixed list of demo models shipped with this repository for
%   tests and documentation. Package path: arduinopio.listExampleModels.
%
%   Syntax:
%       modelNames = arduinopio.listExampleModels()
%
%   Inputs:
%       none
%
%   Outputs:
%       modelNames - string column. Names: uno_blink, uno_analog_pwm, uno_serial,
%           uno_can, piofrtos_multirate.
%
%   Example:
%       names = arduinopio.listExampleModels();
%
%   Other m-files required: none
%   Subfunctions: none
%   MAT-files required: none
%
%   See also: LISTLIBRARYBLOCKS, GETROOTFOLDER

%   Author: Frey, Jed
%   28-Sep-2026; Last revision: 28-Sep-2026

%------------- BEGIN CODE --------------
    modelNames = [
        "uno_blink"
        "uno_analog_pwm"
        "uno_serial"
        "uno_can"
        "piofrtos_multirate"
        ];
end
