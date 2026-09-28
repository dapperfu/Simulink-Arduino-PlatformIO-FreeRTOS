function build_all(options)
%build_all Create every example and generate PlatformIO firmware source.
%   build_all() recreates the example models with piofrtos.tlc selected, then
%   generates code into examples/<model>_piofrtos_rtw. Commit those folders so
%   the generated firmware source can be browsed without running MATLAB.
    arguments
        options.GenerateCodeOnly (1,1) logical = true
    end

    repoRoot = fileparts(mfilename("fullpath"));
    exampleDir = fullfile(repoRoot, "examples");
    setup_piofrtos();
    createArduinoPioExamples();

    modelNames = arduinopio.listExampleModels();
    removeStrayRootBuildFolders(repoRoot, modelNames);

    previousFolder = pwd;
    restoreFolder = onCleanup(@() cd(previousFolder));
    cd(exampleDir);

    previousFileGen = Simulink.fileGenControl("getConfig");
    restoreFileGen = onCleanup(@() restoreFileGenControl(previousFileGen));
    cacheFolder = fullfile(tempdir, "arduinopioExampleBuildCache");
    if ~isfolder(cacheFolder)
        mkdir(cacheFolder);
    end
    Simulink.fileGenControl("set", ...
        CacheFolder=cacheFolder, ...
        CodeGenFolder=exampleDir, ...
        keepPreviousPath=true);

    for modelIndex = 1:numel(modelNames)
        buildExample(exampleDir, modelNames(modelIndex), options.GenerateCodeOnly);
    end

    fprintf("Generated firmware source for %d example models in %s.\n", ...
        numel(modelNames), exampleDir);
end

function buildExample(exampleDir, modelName, generateCodeOnly)
    modelPath = fullfile(exampleDir, modelName + ".slx");
    if ~isfile(modelPath)
        error("arduinopio:ExampleMissing", ...
            "Example model %s was not created. Run createArduinoPioExamples.", modelName);
    end

    if bdIsLoaded(modelName)
        close_system(modelName, 0);
    end
    load_system(modelPath);
    closer = onCleanup(@() close_system(modelName, 0));

    if string(get_param(modelName, "SystemTargetFile")) ~= "piofrtos.tlc"
        piofrtos.configureModel(modelName, ...
            FixedStep=string(get_param(modelName, "FixedStep")));
        save_system(modelName);
    end

    if generateCodeOnly
        slbuild(modelName, "GenerateCodeOnly", true);
    else
        slbuild(modelName);
    end
end

function restoreFileGenControl(previousFileGen)
    Simulink.fileGenControl("setConfig", config=previousFileGen);
end

function removeStrayRootBuildFolders(repoRoot, modelNames)
    for modelIndex = 1:numel(modelNames)
        strayFolder = fullfile(repoRoot, modelNames(modelIndex) + "_piofrtos_rtw");
        if isfolder(strayFolder)
            rmdir(strayFolder, "s");
        end
    end
end
