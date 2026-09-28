function modelName = createMultirateExample(options)
%createMultirateExample Create a two-rate model configured for piofrtos.tlc.
    arguments
        options.ModelName (1,1) string = "piofrtos_multirate"
        options.OpenModel (1,1) logical = true
    end

    modelName = options.ModelName;
    exampleFolder = fileparts(mfilename("fullpath"));
    repoRoot = fileparts(exampleFolder);
    addpath(repoRoot);
    addpath(fullfile(repoRoot, "piofrtos"));
    piofrtos.generateTargetFiles();

    if bdIsLoaded(modelName)
        close_system(modelName, 0);
    end

    new_system(modelName);
    load_system(modelName);

    piofrtos.configureModel(modelName, FixedStep="0.01", StopTime="inf");

    add_block("simulink/Sources/Pulse Generator", modelName + "/PulseFast", ...
        "Position", [80, 50, 150, 90]);
    set_param(modelName + "/PulseFast", ...
        "PulseType", "Sample based", ...
        "Period", "2", ...
        "PulseWidth", "1", ...
        "SampleTime", "0.01");

    add_block("simulink/Math Operations/Gain", modelName + "/GainFast", ...
        "Position", [200, 50, 250, 90], ...
        "Gain", "1");

    add_block("simulink/Sinks/Out1", modelName + "/OutFast", ...
        "Position", [320, 55, 350, 85]);

    add_block("simulink/Sources/Pulse Generator", modelName + "/PulseSlow", ...
        "Position", [80, 160, 150, 200]);
    set_param(modelName + "/PulseSlow", ...
        "PulseType", "Sample based", ...
        "Period", "2", ...
        "PulseWidth", "1", ...
        "SampleTime", "0.1");

    add_block("simulink/Discrete/Unit Delay", modelName + "/DelaySlow", ...
        "Position", [200, 160, 250, 200], ...
        "SampleTime", "0.1");

    add_block("simulink/Sinks/Out1", modelName + "/OutSlow", ...
        "Position", [320, 165, 350, 195]);

    add_line(modelName, "PulseFast/1", "GainFast/1");
    add_line(modelName, "GainFast/1", "OutFast/1");
    add_line(modelName, "PulseSlow/1", "DelaySlow/1");
    add_line(modelName, "DelaySlow/1", "OutSlow/1");

    modelFile = fullfile(exampleFolder, modelName + ".slx");
    save_system(modelName, modelFile);

    if options.OpenModel
        open_system(modelName);
    else
        close_system(modelName);
    end
end
