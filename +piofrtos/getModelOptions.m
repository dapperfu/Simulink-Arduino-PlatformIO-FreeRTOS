function options = getModelOptions(modelName)
%getModelOptions Read PlatformIO target options from a model config set.
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
