classdef tDigitalIoMethods < matlab.unittest.TestCase
    %TDIGITALIOMETHODS - Compares Digital IO across System objects and Level-2 C S-fcns.
    %   Host-simulates Digital Input/Output MATLAB System objects and Level-2 C mex
    %   blocks, and checks library folders for three Digital IO method variants. Fixtures
    %   add matlab, sfcn, and libraries paths. Failure means SimValue or simulation path
    %   regressions, or library layout drift.
    %
    %   Syntax:
    %       result = runtests("tDigitalIoMethods")
    %
    %   Inputs:
    %       none
    %
    %   Outputs:
    %       none. Test methods pass, fail, or throw matlab.unittest results.
    %
    %   Example:
    %       result = runtests("tDigitalIoMethods");
    %
    %   Other m-files required: arduinopio.blocks.common.DigitalInput,
    %       arduinopio.blocks.common.DigitalOutput, createArduinoPioLibrary
    %   Subfunctions: uniqueModelName
    %   MAT-files required: none
    %
    %   See also: TDIGITALSYSTEMOBJECTS, TCOMMONIOSFUNCTIONS

    %   Author: Frey, Jed
    %   28-Sep-2026; Last revision: 28-Sep-2026

    methods (TestClassSetup)
        function addRepoToPath(testCase)
        %ADDREPOTOPATH - Adds repo, matlab, sfcn, and libraries paths for the class.
        %   Applies PathFixture so Digital IO System objects, S-functions, and the
        %   library model resolve during simulation and library checks.
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
        %       runtests("tDigitalIoMethods", "ProcedureName", "addRepoToPath");
        %
        %   See also: TDIGITALIOMETHODS
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
        %SYSTEMOBJECTDIGITALINPUTUSESSIMVALUE - DigitalInput System object uses SimValue.
        %   Builds a fixed-step model with MATLAB System DigitalInput (Pin 2, SimValue 1)
        %   logged to workspace and verifies the last logged sample is true.
        %
        %   Syntax:
        %       systemObjectDigitalInputUsesSimValue(testCase)
        %
        %   Inputs:
        %       testCase - matlab.unittest.TestCase instance supplied by the runner.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       runtests("tDigitalIoMethods", ...
        %           "ProcedureName", "systemObjectDigitalInputUsesSimValue");
        %
        %   See also: TDIGITALIOMETHODS, ARDUINOPIO.BLOCKS.COMMON.DIGITALINPUT
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
        %SYSTEMOBJECTDIGITALOUTPUTSIMULATES - DigitalOutput System object simulates.
        %   Builds a fixed-step model driving DigitalOutput (Pin 13) from a Constant 1 and
        %   verifies sim completes without error under interpreted execution.
        %
        %   Syntax:
        %       systemObjectDigitalOutputSimulates(testCase)
        %
        %   Inputs:
        %       testCase - matlab.unittest.TestCase instance supplied by the runner.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       runtests("tDigitalIoMethods", ...
        %           "ProcedureName", "systemObjectDigitalOutputSimulates");
        %
        %   See also: TDIGITALIOMETHODS, ARDUINOPIO.BLOCKS.COMMON.DIGITALOUTPUT
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
        %LEVEL2CDIGITALINPUTUSESSIMVALUE - Level-2 C digital input uses SimValue 1.
        %   Assumes arduinopio_digital_input_c mex exists. Parameters "2, 0, 0.01, 1"
        %   configure pin, pull, sample time, and SimValue; verifies last logged output
        %   is true. Assumes fail when mex is missing.
        %
        %   Syntax:
        %       level2CDigitalInputUsesSimValue(testCase)
        %
        %   Inputs:
        %       testCase - matlab.unittest.TestCase instance supplied by the runner.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       runtests("tDigitalIoMethods", ...
        %           "ProcedureName", "level2CDigitalInputUsesSimValue");
        %
        %   See also: TDIGITALIOMETHODS
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
        %LEVEL2CDIGITALOUTPUTSIMULATES - Level-2 C digital output simulates Constant 1.
        %   Assumes arduinopio_digital_output_c mex exists. Parameters "13, 0.01" set pin
        %   and sample time; verifies sim completes. Assumes fail when mex is missing.
        %
        %   Syntax:
        %       level2CDigitalOutputSimulates(testCase)
        %
        %   Inputs:
        %       testCase - matlab.unittest.TestCase instance supplied by the runner.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       runtests("tDigitalIoMethods", ...
        %           "ProcedureName", "level2CDigitalOutputSimulates");
        %
        %   See also: TDIGITALIOMETHODS
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
        %LIBRARYLISTSTHREEDIGITALIOMETHODS - Library exposes three Digital IO method trees.
        %   Assumes arduinopio_lib.slx exists. Verifies Level-2 MATLAB, System object, and
        %   Level-2 C folders exist and that Digital Input blocks bind to
        %   arduinopio_digital_input, DigitalInput System, and arduinopio_digital_input_c.
        %
        %   Syntax:
        %       libraryListsThreeDigitalIoMethods(testCase)
        %
        %   Inputs:
        %       testCase - matlab.unittest.TestCase instance supplied by the runner.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       runtests("tDigitalIoMethods", ...
        %           "ProcedureName", "libraryListsThreeDigitalIoMethods");
        %
        %   See also: TDIGITALIOMETHODS, CREATEARDUINOPIOLIBRARY
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
%UNIQUEMODELNAME - Builds a random model name from a short prefix.
%   Concatenates prefix with a random integer in 1e6 so temporary models do not collide
%   across concurrent or repeated test runs.
%
%   Syntax:
%       name = uniqueModelName(prefix)
%
%   Inputs:
%       prefix - char or string prefix for the temporary model name.
%
%   Outputs:
%       name - string scalar unique model name.
%
%   Example:
%       name = uniqueModelName("sysDi");
%
%   See also: TDIGITALIOMETHODS
    name = string(prefix) + string(randi(1e6));
end
