function setSampleTime(block, parameterIndex)
%setSampleTime Apply inherited (-1) or discrete sample time from a dialog parameter.
    arguments
        block
        parameterIndex (1,1) double {mustBeInteger, mustBePositive}
    end

    try
        sampleTime = block.DialogPrm(parameterIndex).Data;
    catch
        block.SampleTimes = [-1, 0];
        return
    end

    if isempty(sampleTime) || sampleTime == -1
        block.SampleTimes = [-1, 0];
    else
        if ~(isscalar(sampleTime) && isnumeric(sampleTime) && isfinite(sampleTime) && sampleTime > 0)
            error("arduinopio:InvalidSampleTime", ...
                "SampleTime must be -1 (inherited) or a positive finite scalar.");
        end
        block.SampleTimes = [double(sampleTime), 0];
    end
end
