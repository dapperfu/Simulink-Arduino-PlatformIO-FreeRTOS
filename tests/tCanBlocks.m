classdef tCanBlocks < matlab.unittest.TestCase
    % Host simulation tests for MCP2515 CAN Transmit and Receive System objects.

    methods (TestClassSetup)
        function addRepoToPath(testCase)
            testsFolder = fileparts(mfilename("fullpath"));
            repoRoot = fileparts(testsFolder);
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture(repoRoot));
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture(fullfile(repoRoot, "matlab")));
        end
    end

    methods (Test)
        function receiveIsIdleOnHost(testCase)
            modelName = uniqueModelName("canRx");
            new_system(modelName);
            load_system(modelName);
            closer = onCleanup(@() close_system(modelName, 0));
            testCase.assertTrue(bdIsLoaded(modelName));

            set_param(modelName, "StopTime", "0.02", "SolverType", "Fixed-step", "FixedStep", "0.01");
            add_block("simulink/User-Defined Functions/MATLAB System", ...
                modelName + "/RX", Position=[80, 40, 240, 120]);
            set_param(modelName + "/RX", "System", "arduinopio.blocks.common.CanReceive");
            set_param(modelName + "/RX", "SimulateUsing", "Interpreted execution");
            set_param(modelName + "/RX", "SampleTime", "0.01");

            add_block("simulink/Sinks/To Workspace", modelName + "/IdLog", Position=[300, 30, 400, 55]);
            add_block("simulink/Sinks/To Workspace", modelName + "/DataLog", Position=[300, 60, 400, 85]);
            add_block("simulink/Sinks/To Workspace", modelName + "/LenLog", Position=[300, 90, 400, 115]);
            add_block("simulink/Sinks/To Workspace", modelName + "/StLog", Position=[300, 120, 400, 145]);
            set_param(modelName + "/IdLog", "VariableName", "canId", "SaveFormat", "Array");
            set_param(modelName + "/DataLog", "VariableName", "canData", "SaveFormat", "Array");
            set_param(modelName + "/LenLog", "VariableName", "canLen", "SaveFormat", "Array");
            set_param(modelName + "/StLog", "VariableName", "canStatus", "SaveFormat", "Array");
            add_line(modelName, "RX/1", "IdLog/1");
            add_line(modelName, "RX/2", "DataLog/1");
            add_line(modelName, "RX/3", "LenLog/1");
            add_line(modelName, "RX/4", "StLog/1");

            simOut = sim(modelName);
            testCase.verifyEqual(simOut.canId(end), uint32(0));
            testCase.verifyEqual(simOut.canData(:, end), zeros(8, 1, "uint8"));
            testCase.verifyEqual(simOut.canLen(end), uint8(0));
            testCase.verifyFalse(logical(simOut.canStatus(end)));
        end

        function transmitAcceptsUint8Payload(testCase)
            modelName = uniqueModelName("canTx");
            new_system(modelName);
            load_system(modelName);
            closer = onCleanup(@() close_system(modelName, 0));
            testCase.assertTrue(bdIsLoaded(modelName));

            set_param(modelName, "StopTime", "0.02", "SolverType", "Fixed-step", "FixedStep", "0.01");
            add_block("simulink/Sources/Constant", modelName + "/u", Position=[40, 40, 80, 70]);
            set_param(modelName + "/u", "Value", "uint8(1:8)", "OutDataTypeStr", "uint8");
            add_block("simulink/User-Defined Functions/MATLAB System", ...
                modelName + "/TX", Position=[140, 36, 280, 84]);
            set_param(modelName + "/TX", "System", "arduinopio.blocks.common.CanTransmit");
            set_param(modelName + "/TX", "SimulateUsing", "Interpreted execution");
            set_param(modelName + "/TX", "SampleTime", "0.01");
            add_line(modelName, "u/1", "TX/1");
            sim(modelName);
        end

        function knownLibDepsIncludesMcp2515(testCase)
            deps = arduinopio.knownLibDeps();
            defines = string({deps.Define});
            libraries = string({deps.LibDep});
            testCase.verifyTrue(any(defines == "ARDUINOPIO_NEED_MCP2515"));
            testCase.verifyTrue(any(libraries == "autowp/autowp-mcp2515"));
        end

        function rejectsOversizedStandardId(testCase)
            testCase.verifyError(@() arduinopio.validateCanIdentifier(2048, false, "MessageId"), ...
                "arduinopio:CanId");
        end
    end
end

function name = uniqueModelName(prefix)
    name = string(prefix) + string(randi(1e6));
end
