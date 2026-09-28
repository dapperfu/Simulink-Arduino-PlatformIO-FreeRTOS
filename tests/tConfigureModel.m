classdef tConfigureModel < matlab.unittest.TestCase
    % Tests for applying the Arduino FreeRTOS (PlatformIO) target to a model.

    methods (TestClassSetup)
        function addRepoToPath(testCase)
            testsFolder = fileparts(mfilename("fullpath"));
            repoRoot = fileparts(testsFolder);
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture(repoRoot));
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture(fullfile(repoRoot, "piofrtos")));
            setup_piofrtos();
        end
    end

    methods (Test)
        function selectsPiofrtosAndUnoDefaults(testCase)
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
