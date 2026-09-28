function command = maskDisplayWithPin(title, options)
%MASKDISPLAYWITHPIN - Build a Simulink mask Display fprintf command that shows a pin.
%   Returns a character/string command for the mask Display parameter. The title
%   is printed on the first line; the label and evaluated expression (default Pin)
%   appear on the second. Package path: arduinopio.maskDisplayWithPin.
%
%   Syntax:
%       command = arduinopio.maskDisplayWithPin(title)
%       command = arduinopio.maskDisplayWithPin(title, Expression=expr, Label=label)
%
%   Inputs:
%       title - (1,1) string. Block title shown on the first mask display line.
%       options.Expression - (1,1) string. Mask expression evaluated for the pin
%           value. Default: "Pin".
%       options.Label - (1,1) string. Text before the pin value. Default: "Pin".
%
%   Outputs:
%       command - string. fprintf-style Display command for set_param MaskDisplay.
%
%   Example:
%       cmd = arduinopio.maskDisplayWithPin("Digital Output", Expression="Pin");
%
%   Other m-files required: none
%   Subfunctions: none
%   MAT-files required: none
%
%   See also: ICONWITHPIN

%   Author: Frey, Jed
%   28-Sep-2026; Last revision: 28-Sep-2026

%------------- BEGIN CODE --------------
    arguments
        title (1,1) string
        options.Expression (1,1) string = "Pin"
        options.Label (1,1) string = "Pin"
    end

    command = "fprintf('" + title + "\\n" + options.Label + " %g', " + options.Expression + ")";
end
