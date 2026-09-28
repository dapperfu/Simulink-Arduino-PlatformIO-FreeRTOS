classdef tDigitalIoMethods < matlab.unittest.TestCase
    % Compare Digital IO simulation across System objects and Level-2 C S-functions.

    methods (TestClassSetup)
        function addRepoToPath(testCase)
            testsFolder = fileparts(mfilename("fullpath"));
            repoRoot = fileparts(testsFolder);
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture(repoRoot));
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture(fullfile(repoRoot, "matlab")));
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture(fullfile(repoRoot, "sfcn")));
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture(fullfile(repoRoot, "libraries")));
        end
    end

    methods (Test)
        function systemObjectDigitalInputUsesSimValue(testCase)
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

        function systemObjectDigitalOutputSimulates(testCase)
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

        function level2CDigitalInputUsesSimValue(testCase)
            testCase.assumeTrue(exist("arduinopio_digital_input_c", "file") == 3, ...
                "Level-2 C mex is not built. Run buildArduinoPioSFunctions.");

            modelName = uniqueModelName("l2cDi");
            new_system(modelName);
            load_system(modelName);
            closer = onCleanup(@() close_system(modelName, 0));
            testCase.assertTrue(bdIsLoaded(modelName));

            set_param(modelName, "StopTime", "0.02", "SolverType", "Fixed-step", "FixedStep", "0.01");
            add_block("built-in/S-Function", modelName + "/DI", Position=[80, 40, 220, 80]);
            set_param(modelName + "/DI", ...
                "FunctionName", "arduinopio_digital_input_c", ...
                "Parameters", "2, 0, 0.01, 1");
            add_block("simulink/Sinks/To Workspace", modelName + "/Log", Position=[280, 45, 380, 75]);
            set_param(modelName + "/Log", "VariableName", "logged", "SaveFormat", "Array");
            add_line(modelName, "DI/1", "Log/1");

            simOut = sim(modelName);
            testCase.verifyTrue(logical(simOut.logged(end)));
        end

        function level2CDigitalOutputSimulates(testCase)
            testCase.assumeTrue(exist("arduinopio_digital_output_c", "file") == 3, ...
                "Level-2 C mex is not built. Run buildArduinoPioSFunctions.");

            modelName = uniqueModelName("l2cDo");
            new_system(modelName);
            load_system(modelName);
            closer = onCleanup(@() close_system(modelName, 0));
            testCase.assertTrue(bdIsLoaded(modelName));

            set_param(modelName, "StopTime", "0.02", "SolverType", "Fixed-step", "FixedStep", "0.01");
            add_block("simulink/Sources/Constant", modelName + "/u", Position=[40, 40, 80, 70]);
            set_param(modelName + "/u", "Value", "1");
            add_block("built-in/S-Function", modelName + "/DO", Position=[140, 36, 280, 74]);
            set_param(modelName + "/DO", ...
                "FunctionName", "arduinopio_digital_output_c", ...
                "Parameters", "13, 0.01");
            add_line(modelName, "u/1", "DO/1");
            sim(modelName);
        end

        function libraryListsThreeDigitalIoMethods(testCase)
            libPath = fullfile(arduinopio.getRootFolder(), "libraries", "arduinopio_lib.slx");
            testCase.assumeTrue(isfile(libPath), "Library not built. Run createArduinoPioLibrary.");

            if bdIsLoaded("arduinopio_lib")
                close_system("arduinopio_lib", 0);
            end
            load_system(libPath);
            closer = onCleanup(@() close_system("arduinopio_lib", 0));

            folders = [
                "arduinopio_lib/Digital IO Methods/Level-2 MATLAB S-Function"
                "arduinopio_lib/Digital IO Methods/MATLAB System object"
                "arduinopio_lib/Digital IO Methods/Level-2 C S-Function"
                ];
            for folderIndex = 1:numel(folders)
                testCase.verifyNotEmpty(find_system(folders(folderIndex), SearchDepth=0));
            end

            testCase.verifyEqual(string(get_param( ...
                "arduinopio_lib/Digital IO Methods/Level-2 MATLAB S-Function/Digital Input", ...
                "FunctionName")), "arduinopio_digital_input");
            testCase.verifyEqual(string(get_param( ...
                "arduinopio_lib/Digital IO Methods/MATLAB System object/Digital Input", ...
                "System")), "arduinopio.blocks.common.DigitalInput");
            testCase.verifyEqual(string(get_param( ...
                "arduinopio_lib/Digital IO Methods/Level-2 C S-Function/Digital Input", ...
                "FunctionName")), "arduinopio_digital_input_c");
        end
    end
end

function name = uniqueModelName(prefix)
    name = string(prefix) + string(randi(1e6));
end
