function options = getDefaultOptions()
%getDefaultOptions Return default PlatformIO and FreeRTOS target options.
    optionTable = piofrtos.getOptionTable();
    options = struct();
    for optionIndex = 1:numel(optionTable)
        options.(optionTable(optionIndex).Name) = optionTable(optionIndex).Default;
    end
end
