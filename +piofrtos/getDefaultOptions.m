function options = getDefaultOptions()
%GETDEFAULTOPTIONS - Return default PlatformIO and FreeRTOS target options.
%   Builds a scalar struct whose fields are the Name values from getOptionTable
%   and whose values are each option's Default. Used by getModelOptions as the
%   baseline before reading model parameters, and by configureModel when
%   applying defaults after switching to piofrtos.tlc.
%
%   Syntax:
%       options = piofrtos.getDefaultOptions()
%
%   Inputs:
%       none
%
%   Outputs:
%       options - scalar struct with fields PioPlatform, PioBoard, PioFramework,
%           PioExtraLibraries, PioMonitorSpeed, PioUpload, PioTaskStackWords.
%           Defaults come from listKnownTargets (first known board) via the option
%           table; monitor speed default is "115200", upload "off".
%
%   Example:
%       % Inspect the default board and FreeRTOS stack depth.
%       options = piofrtos.getDefaultOptions();
%
%   Other m-files required: getOptionTable
%   Subfunctions: none
%   MAT-files required: none
%
%   See also: GETOPTIONTABLE, GETMODELOPTIONS, CONFIGUREMODEL

%   Author: Frey, Jed
%   28-Sep-2026; Last revision: 28-Sep-2026

%------------- BEGIN CODE --------------
    optionTable = piofrtos.getOptionTable();
    options = struct();
    for optionIndex = 1:numel(optionTable)
        options.(optionTable(optionIndex).Name) = optionTable(optionIndex).Default;
    end
end
