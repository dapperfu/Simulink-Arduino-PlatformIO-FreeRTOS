classdef tConfigureModel < matlab.unittest.TestCase
    %TCONFIGUREMODEL - Applies the Arduino FreeRTOS (PlatformIO) target to a model.
    %   Covers piofrtos.configureModel setting STL, solver, and Pio* defaults on a fresh
    %   empty model. Fixtures add the piofrtos path and call setup_piofrtos. Failure means
    %   configureModel does not select the expected target or Uno defaults.
    %
    %   Syntax:
    %       result = runtests("tConfigureModel")
    %
    %   Inputs:
    %       none
    %
    %   Outputs:
    %       none. Test methods pass, fail, or throw matlab.unittest results.
    %
    %   Example:
    %       result = runtests("tConfigureModel");
    %
    %   Other m-files required: piofrtos.configureModel, setup_piofrtos
    %   Subfunctions: none
    %   MAT-files required: none
    %
    %   See also: TEXAMPLEMODELS, PIOFRTOS.CONFIGUREMODEL

    %   Author: Frey, Jed
    %   28-Sep-2026; Last revision: 28-Sep-2026

    methods (TestClassSetup)
        function addRepoToPath(testCase)
        %ADDREPOTOPATH - Adds repo and piofrtos paths and runs setup_piofrtos.
        %   Applies PathFixture for the repository root and piofrtos folder, then calls
        %   setup_piofrtos so configureModel and generated target files resolve.
        %
        %   Syntax:
        %       addRepoToPath(testCase)
        %
        %   Inputs:
        %       testCase - matlab.unittest.TestCase instance supplied by the runner.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       runtests("tConfigureModel", "ProcedureName", "addRepoToPath");
        %
        %   See also: TCONFIGUREMODEL
            testsFolder = fileparts(mfilename("fullpath"));
            repoRoot = fileparts(testsFolder);
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture(repoRoot));
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture(fullfile(repoRoot, "piofrtos")));
            setup_piofrtos();
        end
    end

    methods (Test)
        function selectsPiofrtosAndUnoDefaults(testCase)
        %SELECTSPIOFRTOSANDUNODEFAULTS - configureModel selects STL and Uno defaults.
        %   Creates a temporary model, calls configureModel with FixedStep="0.1", and
        %   verifies piofrtos.tlc/tmf, fixed-step discrete solver, MatFileLogging off, and
        %   PioBoard/Platform/Framework/ExtraLibraries defaults including FreeRTOS.
        %
        %   Syntax:
        %       selectsPiofrtosAndUnoDefaults(testCase)
        %
        %   Inputs:
        %       testCase - matlab.unittest.TestCase instance supplied by the runner.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       runtests("tConfigureModel", ...
        %           "ProcedureName", "selectsPiofrtosAndUnoDefaults");
        %
        %   See also: TCONFIGUREMODEL, PIOFRTOS.CONFIGUREMODEL
            modelName = "cfg" + string(randi(1e9));
            new_system(modelName);
            load_system(modelName);
            closer = onCleanup(@() close_system(modelName, 0));

            piofrtos.configureModel(modelName, FixedStep="0.1");

            testCase.verifyEqual(string(get_param(modelName, "SystemTargetFile")), "piofrtos.tlc");
            testCase.verifyEqual(string(get_param(modelName, "TemplateMakefile")), "piofrtos.tmf");
            testCase.verifyEqual(string(get_param(modelName, "SolverType")), "Fixed-step");
            testCase.verifyEqual(string(get_param(modelName, "Solver")), "FixedStepDiscrete");
            testCase.verifyEqual(string(get_param(modelName, "FixedStep")), "0.1");
            testCase.verifyEqual(string(get_param(modelName, "MatFileLogging")), "off");

            testCase.verifyEqual(string(get_param(modelName, "PioBoard")), "Arduino Uno");
            testCase.verifyEqual(string(get_param(modelName, "PioPlatform")), "atmelavr");
            testCase.verifyEqual(string(get_param(modelName, "PioFramework")), "arduino");
            testCase.verifyEqual(string(get_param(modelName, "PioExtraLibraries")), "feilipu/FreeRTOS");
        end
    end
end
