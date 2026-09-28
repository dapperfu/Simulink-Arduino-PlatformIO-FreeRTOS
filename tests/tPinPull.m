classdef tPinPull < matlab.unittest.TestCase
    % Unit tests for enumerated None / Pull-up / Pull-down input options.

    methods (TestClassSetup)
        function addRepoToPath(testCase)
            testsFolder = fileparts(mfilename("fullpath"));
            repoRoot = fileparts(testsFolder);
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture(repoRoot));
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture(fullfile(repoRoot, "matlab")));
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture(fullfile(repoRoot, "sfcn")));
        end
    end

    methods (Test)
        function namesAreEnumerated(testCase)
            testCase.verifyEqual(arduinopio.pinPullNames(), ["None", "Pull-up", "Pull-down"]);
        end

        function indexMapsDisplayNames(testCase)
            testCase.verifyEqual(arduinopio.pinPullIndex("None"), 0);
            testCase.verifyEqual(arduinopio.pinPullIndex("Pull-up"), 1);
            testCase.verifyEqual(arduinopio.pinPullIndex("Pull-down"), 2);
        end

        function indexMapsNumericValues(testCase)
            testCase.verifyEqual(arduinopio.pinPullIndex(0), 0);
            testCase.verifyEqual(arduinopio.pinPullIndex(1), 1);
            testCase.verifyEqual(arduinopio.pinPullIndex(2), 2);
        end

        function invalidNameErrors(testCase)
            testCase.verifyError(@() arduinopio.pinPullIndex("Enable pull-up"), "arduinopio:InvalidPinPull");
        end

        function pulldownRejectedOnUno(testCase)
            testCase.verifyError(@() arduinopio.validatePinPull("Pull-down"), "arduinopio:InvalidPinPull");
        end

        function noneAndPullupAcceptedOnUno(testCase)
            testCase.verifyWarningFree(@() arduinopio.validatePinPull("None"));
            testCase.verifyWarningFree(@() arduinopio.validatePinPull("Pull-up"));
        end

        function digitalInputAcceptsPullupParameter(testCase)
            output = simulateDigitalInput(testCase, "2, 1, 0.01, 1");
            testCase.verifyTrue(logical(output));
        end
    end
end

function output = simulateDigitalInput(testCase, parameters)
    modelName = "pinPull" + string(randi(1e6));
    new_system(modelName);
    load_system(modelName);
    closer = onCleanup(@() close_system(modelName, 0));
    testCase.assertTrue(bdIsLoaded(modelName));

    set_param(modelName, "StopTime", "0.02", "SolverType", "Fixed-step", "FixedStep", "0.01");
    add_block("simulink/User-Defined Functions/Level-2 MATLAB S-Function", ...
        modelName + "/DUT", Position=[80, 40, 220, 80]);
    set_param(modelName + "/DUT", "FunctionName", "arduinopio_digital_input", "Parameters", parameters);
    add_block("simulink/Sinks/To Workspace", modelName + "/Log", Position=[280, 45, 380, 75]);
    set_param(modelName + "/Log", "VariableName", "logged", "SaveFormat", "Array");
    add_line(modelName, "DUT/1", "Log/1");

    simOut = sim(modelName);
    output = simOut.logged(end, :).';
end
