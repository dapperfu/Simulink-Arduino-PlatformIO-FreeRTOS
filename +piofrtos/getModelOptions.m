function options = getModelOptions(modelName)
%GETMODELOPTIONS - Read PlatformIO target options from a model config set.
%   Starts from getDefaultOptions, then for each Name in getOptionTable reads
%   the model parameter via get_param when available. Missing custom rtwoptions
%   keep their defaults. Returned fields are strings used by writeGeneratedFiles
%   when emitting platformio.ini and FreeRTOS main for the piofrtos target.
%
%   Syntax:
%       options = piofrtos.getModelOptions(modelName)
%
%   Inputs:
%       modelName - (1,1) string name of a Simulink model with (or without)
%           the piofrtos custom options present on the config set.
%
%   Outputs:
%       options - scalar struct with PioPlatform, PioBoard, PioFramework,
%           PioExtraLibraries, PioMonitorSpeed, PioUpload, PioTaskStackWords.
%
%   Example:
%       % Read board and stack settings for firmware generation.
%       options = piofrtos.getModelOptions("blink");
%
%   Other m-files required: getDefaultOptions, getOptionTable
%   Subfunctions: readParameter
%   MAT-files required: none
%
%   See also: GETDEFAULTOPTIONS, GETOPTIONTABLE, WRITEGENERATEDFILES

%   Author: Frey, Jed
%   28-Sep-2026; Last revision: 28-Sep-2026

%------------- BEGIN CODE --------------
    arguments
        modelName (1,1) string
    end

    options = piofrtos.getDefaultOptions();
    optionTable = piofrtos.getOptionTable();

    for optionIndex = 1:numel(optionTable)
        name = optionTable(optionIndex).Name;
        options.(name) = readParameter(modelName, name, options.(name));
    end
end

function value = readParameter(modelName, parameterName, defaultValue)
%READPARAMETER - Read one model parameter as string, else keep the default.
%   Local helper for getModelOptions. Calls get_param; empty or missing
%   parameters leave defaultValue (stringified). Catch covers options that
%   exist only after piofrtos.tlc is selected.
%
%   Syntax:
%       value = readParameter(modelName, parameterName, defaultValue)
%
%   Inputs:
%       modelName - string model name.
%       parameterName - string config parameter name (e.g. "PioBoard").
%       defaultValue - fallback when get_param fails or returns empty.
%
%   Outputs:
%       value - string parameter value or string(defaultValue).
%
%   Example:
%       v = readParameter("blink", "PioMonitorSpeed", "115200");
%
%   See also: GETMODELOPTIONS
    value = string(defaultValue);
    try
        rawValue = get_param(modelName, parameterName);
        if ~isempty(rawValue)
            value = string(rawValue);
        end
    catch
        % Custom rtwoptions are unavailable until this target is selected.
    end
end
