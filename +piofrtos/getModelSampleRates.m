function rates = getModelSampleRates(modelName, buildDir)
%GETMODELSAMPLERATES - Return discrete sample rates mapped to step functions.
%   Discovers discrete periods for the piofrtos FreeRTOS task mapping. Prefers
%   coder.getCodeDescriptor Output interfaces when buildDir exists, otherwise
%   uses Simulink.BlockDiagram.getSampleTimes. Assigns TaskName rateN, step
%   function names, and Priority (faster rates get higher priority). Errors
%   with piofrtos:NoDiscreteRates when no discrete rates are found.
%
%   Syntax:
%       rates = piofrtos.getModelSampleRates(modelName)
%       rates = piofrtos.getModelSampleRates(modelName, buildDir)
%
%   Inputs:
%       modelName - (1,1) string Simulink model name.
%       buildDir - (1,1) string code folder for the descriptor. Default: "".
%           Used only when non-empty and isfolder(buildDir).
%
%   Outputs:
%       rates - struct array with Index, PeriodSeconds, OffsetSeconds,
%           StepFunction, Priority, TaskName for each discrete rate.
%
%   Example:
%       % Map discrete rates after code generation into the RTW folder.
%       rates = piofrtos.getModelSampleRates("blink", buildDir);
%
%   Other m-files required: none
%   Subfunctions: fromCodeDescriptor, fromBlockDiagram, selectRateGroupedSteps, ...
%       assignStepFunctionNames, sortRates, assignPriorities, isDiscretePeriod, ...
%       toDoubleOrEmpty, makeRate, emptyRateArray
%   MAT-files required: none
%
%   See also: EMITFREERTOSMAIN, WRITEGENERATEDFILES, VALIDATEMODELFORTARGET

%   Author: Frey, Jed
%   28-Sep-2026; Last revision: 28-Sep-2026

%------------- BEGIN CODE --------------
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
%FROMCODEDESCRIPTOR - Build rate structs from coder Output function interfaces.
%   Local helper for getModelSampleRates. Reads Output interfaces whose
%   Prototype.Name contains "_step", keeps discrete SamplePeriod values, then
%   selectRateGroupedSteps to prefer rate-grouped stepN names.
%
%   Syntax:
%       rates = fromCodeDescriptor(modelName, buildDir)
%
%   Inputs:
%       modelName - string model name for step naming helpers.
%       buildDir - string folder passed to coder.getCodeDescriptor.
%
%   Outputs:
%       rates - rate struct array, or empty when the descriptor is unavailable.
%
%   Example:
%       rates = fromCodeDescriptor("blink", buildDir);
%
%   See also: GETMODELSAMPLERATES, FROMBLOCKDIAGRAM
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
%FROMBLOCKDIAGRAM - Build rate structs from Simulink block-diagram sample times.
%   Local helper for getModelSampleRates. Uses getSampleTimes, keeps finite
%   positive periods, then assignStepFunctionNames for model_step / model_stepN.
%
%   Syntax:
%       rates = fromBlockDiagram(modelName)
%
%   Inputs:
%       modelName - string model name.
%
%   Outputs:
%       rates - rate struct array of discrete sample times.
%
%   Example:
%       rates = fromBlockDiagram("blink");
%
%   See also: GETMODELSAMPLERATES, FROMCODEDESCRIPTOR
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
%SELECTRATEGROUPEDSTEPS - Prefer *_stepN interfaces when rate grouping is used.
%   Local helper for fromCodeDescriptor. If any StepFunction ends with
%   _step followed by digits, keeps only those entries. Then calls
%   assignStepFunctionNames with OverwriteEmpty=false.
%
%   Syntax:
%       rates = selectRateGroupedSteps(rates, modelName)
%
%   Inputs:
%       rates - rate struct array possibly mixing grouped and ungrouped steps.
%       modelName - string model name for empty step-name fill-in.
%
%   Outputs:
%       rates - filtered/sorted rates with TaskName and Index updated as needed.
%
%   Example:
%       rates = selectRateGroupedSteps(rates, "blink");
%
%   See also: FROMCODEDESCRIPTOR, ASSIGNSTEPFUNCTIONNAMES
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
%ASSIGNSTEPFUNCTIONNAMES - Sort rates and assign step and task names.
%   Local helper for getModelSampleRates. Sorts by PeriodSeconds ascending.
%   Sets Index and TaskName rate0..rateN-1. When OverwriteEmpty is true (default)
%   or StepFunction is empty, sets model_step for one rate else model_stepN.
%
%   Syntax:
%       rates = assignStepFunctionNames(rates, modelName)
%       rates = assignStepFunctionNames(rates, modelName, OverwriteEmpty=false)
%
%   Inputs:
%       rates - rate struct array.
%       modelName - (1,1) string model name prefix for step functions.
%       options.OverwriteEmpty - (1,1) logical. Default: true. When false,
%           existing non-empty StepFunction values are preserved.
%
%   Outputs:
%       rates - updated rate struct array.
%
%   Example:
%       rates = assignStepFunctionNames(rates, "blink");
%
%   See also: SORTRATES, SELECTRATEGROUPEDSTEPS
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
%SORTRATES - Sort rate structs by PeriodSeconds ascending.
%   Local helper for assignStepFunctionNames and assignPriorities. No-op on
%   empty input.
%
%   Syntax:
%       rates = sortRates(rates)
%
%   Inputs:
%       rates - rate struct array with PeriodSeconds field.
%
%   Outputs:
%       rates - same structs ordered from fastest to slowest period.
%
%   Example:
%       rates = sortRates(rates);
%
%   See also: ASSIGNPRIORITIES, ASSIGNSTEPFUNCTIONNAMES
    if isempty(rates)
        return
    end
    [~, order] = sort([rates.PeriodSeconds], "ascend");
    rates = rates(order);
end

function rates = assignPriorities(rates)
%ASSIGNPRIORITIES - Sort rates and set FreeRTOS priorities (fastest highest).
%   Local helper called at the end of getModelSampleRates. Priority equals
%   numRates - rateIndex + 1 so the fastest rate gets the highest priority
%   offset above tskIDLE_PRIORITY in emitFreeRtosMain.
%
%   Syntax:
%       rates = assignPriorities(rates)
%
%   Inputs:
%       rates - non-empty rate struct array.
%
%   Outputs:
%       rates - sorted rates with Index, TaskName, and Priority filled.
%
%   Example:
%       rates = assignPriorities(rates);
%
%   See also: GETMODELSAMPLERATES, EMITFREERTOSMAIN
    rates = sortRates(rates);
    numRates = numel(rates);
    for rateIndex = 1:numRates
        rates(rateIndex).Index = rateIndex - 1;
        rates(rateIndex).TaskName = "rate" + string(rateIndex-1);
        rates(rateIndex).Priority = numRates - rateIndex + 1;
    end
end

function tf = isDiscretePeriod(periodSeconds)
%ISDISCRETEPERIOD - True for a finite positive numeric sample period.
%   Local helper for rate discovery. Uses toDoubleOrEmpty then checks finite
%   and greater than zero (excludes continuous/triggered non-numeric cases).
%
%   Syntax:
%       tf = isDiscretePeriod(periodSeconds)
%
%   Inputs:
%       periodSeconds - numeric or convertible period candidate.
%
%   Outputs:
%       tf - logical true when the period is a usable discrete seconds value.
%
%   Example:
%       tf = isDiscretePeriod(0.01);
%
%   See also: TODOUBLEOREMPTY, FROMCODEDESCRIPTOR
    periodSeconds = toDoubleOrEmpty(periodSeconds);
    tf = ~isempty(periodSeconds) && isfinite(periodSeconds) && periodSeconds > 0;
end

function value = toDoubleOrEmpty(rawValue)
%TODOUBLEOREMPTY - Convert a timing value to a scalar double, else [].
%   Local helper for getModelSampleRates. Empty or non-numeric timing objects
%   yield []. Scalar numeric doubles are returned as-is.
%
%   Syntax:
%       value = toDoubleOrEmpty(rawValue)
%
%   Inputs:
%       rawValue - sample period/offset from code descriptor or similar.
%
%   Outputs:
%       value - scalar double, or [] when conversion is not possible.
%
%   Example:
%       value = toDoubleOrEmpty(0.1);
%
%   See also: ISDISCRETEPERIOD
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
%MAKERATE - Construct one rate struct for FreeRTOS task mapping.
%   Local helper for fromCodeDescriptor and fromBlockDiagram. Initial
%   Priority is 1; TaskName is "rate" + index until assignPriorities renumbers.
%
%   Syntax:
%       rate = makeRate(index, periodSeconds, offsetSeconds, stepFunction)
%
%   Inputs:
%       index - numeric Index field (often numel(rates) before append).
%       periodSeconds - discrete period in seconds.
%       offsetSeconds - sample offset in seconds.
%       stepFunction - string step function name, or "" to fill later.
%
%   Outputs:
%       rate - scalar struct with Index, PeriodSeconds, OffsetSeconds,
%           StepFunction, Priority, TaskName.
%
%   Example:
%       rate = makeRate(0, 0.01, 0, "blink_step");
%
%   See also: EMPTYRATEARRAY, GETMODELSAMPLERATES
    rate = struct( ...
        "Index", index, ...
        "PeriodSeconds", double(periodSeconds), ...
        "OffsetSeconds", double(offsetSeconds), ...
        "StepFunction", string(stepFunction), ...
        "Priority", 1, ...
        "TaskName", "rate" + string(index));
end

function rates = emptyRateArray()
%EMPTYRATEARRAY - Return a 0x0 rate struct with the standard fields.
%   Local helper for getModelSampleRates and its discovery functions so
%   concatenation preserves field names.
%
%   Syntax:
%       rates = emptyRateArray()
%
%   Inputs:
%       none
%
%   Outputs:
%       rates - empty struct with Index, PeriodSeconds, OffsetSeconds,
%           StepFunction, Priority, TaskName fields.
%
%   Example:
%       rates = emptyRateArray();
%
%   See also: MAKERATE, GETMODELSAMPLERATES
    rates = struct( ...
        "Index", {}, ...
        "PeriodSeconds", {}, ...
        "OffsetSeconds", {}, ...
        "StepFunction", {}, ...
        "Priority", {}, ...
        "TaskName", {});
end
