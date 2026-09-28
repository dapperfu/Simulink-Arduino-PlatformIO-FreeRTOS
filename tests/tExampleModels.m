classdef tExampleModels < matlab.unittest.TestCase
    % Example models must select piofrtos.tlc so they build for Arduino.

    methods (TestClassSetup)
        function addRepoToPath(testCase)
            testsFolder = fileparts(mfilename("fullpath"));
            repoRoot = fileparts(testsFolder);
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture(repoRoot));
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture(fullfile(repoRoot, "matlab")));
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture(fullfile(repoRoot, "piofrtos")));
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture(fullfile(repoRoot, "examples")));
            setup_piofrtos();
        end
    end

    methods (Test)
        function everyExampleSelectsPiofrtos(testCase)
            createArduinoPioExamples();
            exampleDir = fullfile(arduinopio.getRootFolder(), "examples");
            modelNames = arduinopio.listExampleModels();
            testCase.verifyGreaterThanOrEqual(numel(modelNames), 5);

            for modelIndex = 1:numel(modelNames)
                modelName = modelNames(modelIndex);
                modelPath = fullfile(exampleDir, modelName + ".slx");
                testCase.assertTrue(isfile(modelPath), "Missing " + modelPath);

                load_system(modelPath);
                closer = onCleanup(@() close_system(modelName, 0));

                testCase.verifyEqual(string(get_param(modelName, "SystemTargetFile")), ...
                    "piofrtos.tlc", modelName + " must use piofrtos.tlc");
                testCase.verifyEqual(string(get_param(modelName, "TemplateMakefile")), ...
                    "piofrtos.tmf", modelName + " must use piofrtos.tmf");
                testCase.verifyEqual(string(get_param(modelName, "PioBoard")), "Arduino Uno");
            end
        end
    end
end
