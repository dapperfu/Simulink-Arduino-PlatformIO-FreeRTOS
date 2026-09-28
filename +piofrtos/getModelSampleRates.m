function rates = getModelSampleRates(modelName, buildDir)
%getModelSampleRates Return discrete sample rates mapped to step functions.
%   Prefers coder.getCodeDescriptor when generated code is available, then
%   falls back to Simulink.BlockDiagram.getSampleTimes.
    arguments
        modelName (1,1) string
        buildDir (1,1) string = ""
    end

    rates = emptyRateArray();

    if strlength(buildDir) > 0 && isfolder(buildDir)
        rates = fromCodeDescriptor(modelName, buildDir);
    end

    if isempty(rates)
        rates = fromBlockDiagram(modelName);
    end

    if isempty(rates)
        error("piofrtos:NoDiscreteRates", ...
            "Model %s has no discrete sample rates to map to FreeRTOS tasks.", ...
            modelName);
    end

    rates = assignPriorities(rates);
end

function rates = fromCodeDescriptor(modelName, buildDir)
    rates = emptyRateArray();
    try
        codeDescriptor = coder.getCodeDescriptor(char(buildDir));
        functionInterfaces = codeDescriptor.getFunctionInterfaces("Output");
    catch
        % Fall back to Simulink sample times when the descriptor is not ready.
        return
    end

    if isempty(functionInterfaces)
        return
    end

    for functionIndex = 1:numel(functionInterfaces)
        functionInterface = functionInterfaces(functionIndex);
        stepName = string(functionInterface.Prototype.Name);
        if ~contains(stepName, "_step")
            continue
        end

        periodSeconds = toDoubleOrEmpty(functionInterface.Timing.SamplePeriod);
        offsetSeconds = toDoubleOrEmpty(functionInterface.Timing.SampleOffset);
        if ~isDiscretePeriod(periodSeconds)
            continue
        end
        if isempty(offsetSeconds)
            offsetSeconds = 0;
        end

        rates(end+1, 1) = makeRate(numel(rates), periodSeconds, offsetSeconds, stepName); %#ok<AGROW>
    end

    rates = selectRateGroupedSteps(rates, modelName);
end

function rates = fromBlockDiagram(modelName)
    rates = emptyRateArray();
    sampleTimes = Simulink.BlockDiagram.getSampleTimes(char(modelName));

    for sampleIndex = 1:numel(sampleTimes)
        sampleValue = sampleTimes(sampleIndex).Value;
        if ~isnumeric(sampleValue) || isempty(sampleValue)
            continue
        end

        periodSeconds = sampleValue(1);
        if ~isDiscretePeriod(periodSeconds)
            continue
        end

        if numel(sampleValue) > 1
            offsetSeconds = sampleValue(2);
        else
            offsetSeconds = 0;
        end

        rates(end+1, 1) = makeRate(numel(rates), periodSeconds, offsetSeconds, ""); %#ok<AGROW>
    end

    rates = assignStepFunctionNames(rates, modelName);
end

function rates = selectRateGroupedSteps(rates, modelName)
    if isempty(rates)
        return
    end

    stepNames = string({rates.StepFunction});
    isRateGrouped = endsWith(stepNames, regexpPattern("_step[0-9]+"));
    if any(isRateGrouped)
        rates = rates(isRateGrouped);
    end

    rates = assignStepFunctionNames(rates, modelName, OverwriteEmpty=false);
end

function rates = assignStepFunctionNames(rates, modelName, options)
    arguments
        rates
        modelName (1,1) string
        options.OverwriteEmpty (1,1) logical = true
    end

    rates = sortRates(rates);
    useRateGrouping = numel(rates) > 1;

    for rateIndex = 1:numel(rates)
        rates(rateIndex).Index = rateIndex - 1;
        rates(rateIndex).TaskName = "rate" + string(rateIndex-1);
        hasName = strlength(string(rates(rateIndex).StepFunction)) > 0;
        if hasName && ~options.OverwriteEmpty
            continue
        end
        if useRateGrouping
            rates(rateIndex).StepFunction = modelName + "_step" + string(rateIndex-1);
        else
            rates(rateIndex).StepFunction = modelName + "_step";
        end
    end
end

function rates = sortRates(rates)
    if isempty(rates)
        return
    end
    [~, order] = sort([rates.PeriodSeconds], "ascend");
    rates = rates(order);
end

function rates = assignPriorities(rates)
    rates = sortRates(rates);
    numRates = numel(rates);
    for rateIndex = 1:numRates
        rates(rateIndex).Index = rateIndex - 1;
        rates(rateIndex).TaskName = "rate" + string(rateIndex-1);
        rates(rateIndex).Priority = numRates - rateIndex + 1;
    end
end

function tf = isDiscretePeriod(periodSeconds)
    periodSeconds = toDoubleOrEmpty(periodSeconds);
    tf = ~isempty(periodSeconds) && isfinite(periodSeconds) && periodSeconds > 0;
end

function value = toDoubleOrEmpty(rawValue)
    value = [];
    if isempty(rawValue)
        return
    end
    try
        numericValue = double(rawValue);
    catch
        % Non-numeric timing objects are treated as non-discrete.
        return
    end
    if isnumeric(numericValue) && isscalar(numericValue)
        value = numericValue;
    end
end

function rate = makeRate(index, periodSeconds, offsetSeconds, stepFunction)
    rate = struct( ...
        "Index", index, ...
        "PeriodSeconds", double(periodSeconds), ...
        "OffsetSeconds", double(offsetSeconds), ...
        "StepFunction", string(stepFunction), ...
        "Priority", 1, ...
        "TaskName", "rate" + string(index));
end

function rates = emptyRateArray()
    rates = struct( ...
        "Index", {}, ...
        "PeriodSeconds", {}, ...
        "OffsetSeconds", {}, ...
        "StepFunction", {}, ...
        "Priority", {}, ...
        "TaskName", {});
end
