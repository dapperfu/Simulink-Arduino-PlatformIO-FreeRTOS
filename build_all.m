function build_all(options)
%BUILD_ALL - Recreate examples and generate PlatformIO firmware source.
%   Calls setup_piofrtos and createArduinoPioExamples, removes stray
%   <model>_piofrtos_rtw folders at the repo root, then builds every model from
%   arduinopio.listExampleModels into examples/ with Simulink.fileGenControl
%   CacheFolder under tempdir. By default GenerateCodeOnly is true so firmware
%   sources can be committed without a full PlatformIO compile.
%
%   Syntax:
%       build_all()
%       build_all(GenerateCodeOnly=false)
%
%   Inputs:
%       options.GenerateCodeOnly - If true, slbuild GenerateCodeOnly (default true)
%
%   Outputs:
%       none
%
%   Example:
%       build_all();
%       build_all(GenerateCodeOnly=false);
%
%   Other m-files required: setup_piofrtos, createArduinoPioExamples,
%       arduinopio.listExampleModels, piofrtos.configureModel
%   Subfunctions: buildExample, restoreFileGenControl, removeStrayRootBuildFolders
%   MAT-files required: none
%
%   See also: CREATEARDUINOPIOEXAMPLES, SETUP_PIOFRTOS, INSTALLARDUINOPIO

%   Author: Frey, Jed
%   28-Sep-2026; Last revision: 28-Sep-2026

%------------- BEGIN CODE --------------

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
%BUILDEXAMPLE - Ensure piofrtos.tlc and code-generate one example model.
%   Loads exampleDir/modelName.slx, errors if missing, and if SystemTargetFile
%   is not piofrtos.tlc calls piofrtos.configureModel with the current FixedStep
%   then saves. Runs slbuild with GenerateCodeOnly when generateCodeOnly is true,
%   otherwise a full slbuild. Always closes the model via onCleanup.
%
%   Syntax:
%       buildExample(exampleDir, modelName, generateCodeOnly)
%
%   Inputs:
%       exampleDir       - Folder containing the .slx
%       modelName        - Model name without extension
%       generateCodeOnly - Logical passed through to slbuild
%
%   Outputs:
%       none
%
%   Example:
%       buildExample(exampleDir, "uno_blink", true);
%
%   See also: BUILD_ALL, PIOFRTOS.CONFIGUREMODEL

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
%RESTOREFILEGENCONTROL - Restore a prior Simulink.fileGenControl configuration.
%   Applies previousFileGen captured before build_all redirected CacheFolder and
%   CodeGenFolder, so MATLAB file generation settings return to the caller state.
%
%   Syntax:
%       restoreFileGenControl(previousFileGen)
%
%   Inputs:
%       previousFileGen - Config object from Simulink.fileGenControl("getConfig")
%
%   Outputs:
%       none
%
%   Example:
%       restoreFileGenControl(previousFileGen);
%
%   See also: BUILD_ALL

    Simulink.fileGenControl("setConfig", config=previousFileGen);
end

function removeStrayRootBuildFolders(repoRoot, modelNames)
%REMOVESTRAYROOTBUILDFOLDERS - Delete misplaced <model>_piofrtos_rtw at repo root.
%   For each modelNames entry, removes repoRoot/<model>_piofrtos_rtw when that
%   folder exists so generated firmware stays under examples/ after fileGenControl
%   is applied.
%
%   Syntax:
%       removeStrayRootBuildFolders(repoRoot, modelNames)
%
%   Inputs:
%       repoRoot   - Repository root folder
%       modelNames - String array of example model names
%
%   Outputs:
%       none
%
%   Example:
%       removeStrayRootBuildFolders(repoRoot, modelNames);
%
%   See also: BUILD_ALL

    for modelIndex = 1:numel(modelNames)
        strayFolder = fullfile(repoRoot, modelNames(modelIndex) + "_piofrtos_rtw");
        if isfolder(strayFolder)
            rmdir(strayFolder, "s");
        end
    end
end
