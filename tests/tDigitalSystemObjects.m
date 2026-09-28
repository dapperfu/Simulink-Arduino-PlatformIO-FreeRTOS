classdef tDigitalSystemObjects < matlab.unittest.TestCase
    %TDIGITALSYSTEMOBJECTS - Simulation tests for Digital Input/Output System objects.
    %   Host-simulates arduinopio.blocks.common.DigitalInput and DigitalOutput under
    %   interpreted execution. Fixtures add matlab and sfcn paths. Failure means SimValue
    %   or output simulation regressions in the System object implementations.
    %
    %   Syntax:
    %       result = runtests("tDigitalSystemObjects")
    %
    %   Inputs:
    %       none
    %
    %   Outputs:
    %       none. Test methods pass, fail, or throw matlab.unittest results.
    %
    %   Example:
    %       result = runtests("tDigitalSystemObjects");
    %
    %   Other m-files required: arduinopio.blocks.common.DigitalInput,
    %       arduinopio.blocks.common.DigitalOutput
    %   Subfunctions: uniqueModelName
    %   MAT-files required: none
    %
    %   See also: TDIGITALIOMETHODS, ARDUINOPIO.BLOCKS.COMMON.DIGITALINPUT

    %   Author: Frey, Jed
    %   28-Sep-2026; Last revision: 28-Sep-2026

    methods (TestClassSetup)
        function addRepoToPath(testCase)
        %ADDREPOTOPATH - Adds repo, matlab, and sfcn paths for the class.
        %   Applies PathFixture so Digital Input/Output System objects resolve during
        %   host simulation.
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
        %       runtests("tDigitalSystemObjects", "ProcedureName", "addRepoToPath");
        %
        %   See also: TDIGITALSYSTEMOBJECTS
            testsFolder = fileparts(mfilename("fullpath"));
            repoRoot = fileparts(testsFolder);
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture(repoRoot));
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture(fullfile(repoRoot, "matlab")));
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture(fullfile(repoRoot, "sfcn")));
        end
    end

    methods (Test)
        function digitalInputUsesSimValue(testCase)
        %DIGITALINPUTUSESSIMVALUE - DigitalInput outputs the configured SimValue.
        %   Builds a fixed-step model with MATLAB System DigitalInput (Pin 2, SimValue 1)
        %   logged to workspace and verifies the last logged sample is true.
        %
        %   Syntax:
        %       digitalInputUsesSimValue(testCase)
        %
        %   Inputs:
        %       testCase - matlab.unittest.TestCase instance supplied by the runner.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       runtests("tDigitalSystemObjects", ...
        %           "ProcedureName", "digitalInputUsesSimValue");
        %
        %   See also: TDIGITALSYSTEMOBJECTS, ARDUINOPIO.BLOCKS.COMMON.DIGITALINPUT
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
        %DIGITALOUTPUTSIMULATES - DigitalOutput System object simulates without error.
        %   Builds a fixed-step model driving DigitalOutput (Pin 13) from Constant 1 under
        %   interpreted execution and verifies sim completes.
        %
        %   Syntax:
        %       digitalOutputSimulates(testCase)
        %
        %   Inputs:
        %       testCase - matlab.unittest.TestCase instance supplied by the runner.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       runtests("tDigitalSystemObjects", ...
        %           "ProcedureName", "digitalOutputSimulates");
        %
        %   See also: TDIGITALSYSTEMOBJECTS, ARDUINOPIO.BLOCKS.COMMON.DIGITALOUTPUT
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
%   See also: TDIGITALSYSTEMOBJECTS
    name = string(prefix) + string(randi(1e6));
end
