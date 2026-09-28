function configureModel(modelName, options)
%configureModel Apply the Arduino FreeRTOS (PlatformIO) target to a model.

    arguments
        modelName (1,1) string
        options.FixedStep (1,1) string = "0.01"
        options.StopTime (1,1) string = "inf"
    end

    piofrtos.generateTargetFiles();

    set_param(modelName, SolverType="Fixed-step");
    set_param(modelName, Solver="FixedStepDiscrete");
    set_param(modelName, FixedStep=options.FixedStep);
    set_param(modelName, StopTime=options.StopTime);
    set_param(modelName, EnableMultiTasking="on");

    configSet = getActiveConfigSet(modelName);
    switchTarget(configSet, "piofrtos.tlc", []);

    set_param(modelName, TemplateMakefile="piofrtos.tmf");
    set_param(modelName, TargetLang="C");
    set_param(modelName, GenerateMakefile="on");
    set_param(modelName, MakeCommand="make_rtw");
    set_param(modelName, MatFileLogging="off");
    try
        set_param(modelName, GenerateSampleERTMain="off");
    catch
        % GenerateSampleERTMain is not on every config set.
    end

    defaults = piofrtos.getDefaultOptions();
    optionTable = piofrtos.getOptionTable();
    for optionIndex = 1:numel(optionTable)
        optionName = optionTable(optionIndex).Name;
        try
            set_param(modelName, optionName, defaults.(optionName));
        catch
            % Custom rtwoptions are unavailable until this target is selected.
        end
    end
end
