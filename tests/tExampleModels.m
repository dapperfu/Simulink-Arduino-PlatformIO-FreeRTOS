classdef tExampleModels < matlab.unittest.TestCase
    %TEXAMPLEMODELS - Example models must select piofrtos.tlc for Arduino builds.
    %   Regenerates examples via createArduinoPioExamples, lists models with
    %   arduinopio.listExampleModels, and verifies each uses piofrtos.tlc/tmf and Arduino
    %   Uno. Fixtures add matlab, piofrtos, and examples paths and call setup_piofrtos.
    %   Failure means an example targets the wrong STL or board default.
    %
    %   Syntax:
    %       result = runtests("tExampleModels")
    %
    %   Inputs:
    %       none
    %
    %   Outputs:
    %       none. Test methods pass, fail, or throw matlab.unittest results.
    %
    %   Example:
    %       result = runtests("tExampleModels");
    %
    %   Other m-files required: createArduinoPioExamples, arduinopio.listExampleModels,
    %       setup_piofrtos
    %   Subfunctions: none
    %   MAT-files required: none
    %
    %   See also: TCONFIGUREMODEL, CREATEARDUINOPIOEXAMPLES

    %   Author: Frey, Jed
    %   28-Sep-2026; Last revision: 28-Sep-2026

    methods (TestClassSetup)
        function addRepoToPath(testCase)
        %ADDREPOTOPATH - Adds example-related paths and runs setup_piofrtos.
        %   Applies PathFixture for repo, matlab, piofrtos, and examples, then calls
        %   setup_piofrtos so example rebuild helpers and target files resolve.
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
        %       runtests("tExampleModels", "ProcedureName", "addRepoToPath");
        %
        %   See also: TEXAMPLEMODELS
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
        %EVERYEXAMPLESELECTSPIOFRTOS - Every example model uses piofrtos and Uno.
        %   Rebuilds examples, requires at least five models, loads each .slx, and
        %   verifies SystemTargetFile piofrtos.tlc, TemplateMakefile piofrtos.tmf, and
        %   PioBoard Arduino Uno.
        %
        %   Syntax:
        %       everyExampleSelectsPiofrtos(testCase)
        %
        %   Inputs:
        %       testCase - matlab.unittest.TestCase instance supplied by the runner.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       runtests("tExampleModels", ...
        %           "ProcedureName", "everyExampleSelectsPiofrtos");
        %
        %   See also: TEXAMPLEMODELS, ARDUINOPIO.LISTEXAMPLEMODELS
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
