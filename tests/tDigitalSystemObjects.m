classdef tDigitalSystemObjects < matlab.unittest.TestCase
    % Simulation tests for Digital Input/Output MATLAB System objects.

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
        function digitalInputUsesSimValue(testCase)
            modelName = uniqueModelName("sysDi");
            new_system(modelName);
            load_system(modelName);
            closer = onCleanup(@() close_system(modelName, 0));
            testCase.assertTrue(bdIsLoaded(modelName));

            set_param(modelName, "StopTime", "0.02", "SolverType", "Fixed-step", "FixedStep", "0.01");
            add_block("simulink/User-Defined Functions/MATLAB System", ...
                modelName + "/DI", Position=[80, 40, 220, 80]);
            set_param(modelName + "/DI", ...
                "System", "arduinopio.blocks.common.DigitalInput", ...
                "SimulateUsing", "Interpreted execution", ...
                "Pin", "2", ...
                "SampleTime", "0.01", ...
                "SimValue", "1");
            add_block("simulink/Sinks/To Workspace", modelName + "/Log", Position=[280, 45, 380, 75]);
            set_param(modelName + "/Log", "VariableName", "logged", "SaveFormat", "Array");
            add_line(modelName, "DI/1", "Log/1");

            simOut = sim(modelName);
            testCase.verifyTrue(logical(simOut.logged(end)));
        end

        function digitalOutputSimulates(testCase)
            modelName = uniqueModelName("sysDo");
            new_system(modelName);
            load_system(modelName);
            closer = onCleanup(@() close_system(modelName, 0));
            testCase.assertTrue(bdIsLoaded(modelName));

            set_param(modelName, "StopTime", "0.02", "SolverType", "Fixed-step", "FixedStep", "0.01");
            add_block("simulink/Sources/Constant", modelName + "/u", Position=[40, 40, 80, 70]);
            set_param(modelName + "/u", "Value", "1");
            add_block("simulink/User-Defined Functions/MATLAB System", ...
                modelName + "/DO", Position=[140, 36, 280, 74]);
            set_param(modelName + "/DO", ...
                "System", "arduinopio.blocks.common.DigitalOutput", ...
                "SimulateUsing", "Interpreted execution", ...
                "Pin", "13", ...
                "SampleTime", "0.01");
            add_line(modelName, "u/1", "DO/1");
            sim(modelName);
        end
    end
end

function name = uniqueModelName(prefix)
    name = string(prefix) + string(randi(1e6));
end
