classdef tCommonIoSFunctions < matlab.unittest.TestCase
    % Simulation tests for common Digital, Analog, and Serial Level-2 S-functions.

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
        function digitalInputUsesSimulationValue(testCase)
            output = simulateSourceBlock(testCase, "arduinopio_digital_input", "2, 0, 0.01, 1");
            testCase.verifyTrue(logical(output));
        end

        function analogInputUsesSimulationCounts(testCase)
            output = simulateSourceBlock(testCase, "arduinopio_analog_input", "0, 0.01, 512");
            testCase.verifyEqual(output, uint16(512));
        end

        function serialReceiveReturnsIdleOnHost(testCase)
            [data, status] = simulateSerialReceive(testCase);
            testCase.verifyEqual(data, zeros(2, 1, "uint8"));
            testCase.verifyFalse(logical(status));
        end

        function digitalAndAnalogOutputsSimulate(testCase)
            modelName = uniqueModelName("ioOut");
            new_system(modelName);
            load_system(modelName);
            closer = onCleanup(@() close_system(modelName, 0));
            testCase.assertTrue(bdIsLoaded(modelName));

            set_param(modelName, "StopTime", "0.02", "SolverType", "Fixed-step", "FixedStep", "0.01");
            add_block("simulink/Sources/Constant", modelName + "/uDig", Position=[40, 40, 80, 70]);
            add_block("simulink/Sources/Constant", modelName + "/uAn", Position=[40, 120, 80, 150]);
            set_param(modelName + "/uDig", "Value", "1");
            set_param(modelName + "/uAn", "Value", "128");

            add_block("simulink/User-Defined Functions/Level-2 MATLAB S-Function", ...
                modelName + "/DOut", Position=[140, 36, 250, 74]);
            set_param(modelName + "/DOut", "FunctionName", "arduinopio_digital_output", "Parameters", "13, 0.01");

            add_block("simulink/User-Defined Functions/Level-2 MATLAB S-Function", ...
                modelName + "/AOut", Position=[140, 116, 250, 154]);
            set_param(modelName + "/AOut", "FunctionName", "arduinopio_analog_output", "Parameters", "5, 0.01");

            add_line(modelName, "uDig/1", "DOut/1");
            add_line(modelName, "uAn/1", "AOut/1");
            sim(modelName);
        end

        function serialTransmitAcceptsUint8(testCase)
            modelName = uniqueModelName("ioTx");
            new_system(modelName);
            load_system(modelName);
            closer = onCleanup(@() close_system(modelName, 0));
            testCase.assertTrue(bdIsLoaded(modelName));

            set_param(modelName, "StopTime", "0.02", "SolverType", "Fixed-step", "FixedStep", "0.01");
            add_block("simulink/Sources/Constant", modelName + "/u", Position=[40, 40, 80, 70]);
            set_param(modelName + "/u", "Value", "uint8(65)", "OutDataTypeStr", "uint8");

            add_block("simulink/User-Defined Functions/Level-2 MATLAB S-Function", ...
                modelName + "/TX", Position=[140, 36, 260, 74]);
            set_param(modelName + "/TX", "FunctionName", "arduinopio_serial_transmit", ...
                "Parameters", "0, 9600, 0.01");
            add_line(modelName, "u/1", "TX/1");
            sim(modelName);
        end
    end
end

function output = simulateSourceBlock(testCase, sfcnName, parameters)
    modelName = uniqueModelName("ioSrc");
    new_system(modelName);
    load_system(modelName);
    closer = onCleanup(@() close_system(modelName, 0));
    testCase.assertTrue(bdIsLoaded(modelName));

    set_param(modelName, "StopTime", "0.02", "SolverType", "Fixed-step", "FixedStep", "0.01");
    add_block("simulink/User-Defined Functions/Level-2 MATLAB S-Function", ...
        modelName + "/DUT", Position=[80, 40, 220, 80]);
    set_param(modelName + "/DUT", "FunctionName", sfcnName, "Parameters", parameters);
    add_block("simulink/Sinks/To Workspace", modelName + "/Log", Position=[280, 45, 380, 75]);
    set_param(modelName + "/Log", "VariableName", "logged", "SaveFormat", "Array");
    add_line(modelName, "DUT/1", "Log/1");

    simOut = sim(modelName);
    output = simOut.logged(end, :).';
end

function [data, status] = simulateSerialReceive(testCase)
    modelName = uniqueModelName("ioRx");
    new_system(modelName);
    load_system(modelName);
    closer = onCleanup(@() close_system(modelName, 0));
    testCase.assertTrue(bdIsLoaded(modelName));

    set_param(modelName, "StopTime", "0.02", "SolverType", "Fixed-step", "FixedStep", "0.01");
    add_block("simulink/User-Defined Functions/Level-2 MATLAB S-Function", ...
        modelName + "/RX", Position=[80, 40, 240, 100]);
    set_param(modelName + "/RX", "FunctionName", "arduinopio_serial_receive", ...
        "Parameters", "0, 9600, 2, 0.01");
    add_block("simulink/Sinks/To Workspace", modelName + "/DataLog", Position=[300, 40, 410, 70]);
    add_block("simulink/Sinks/To Workspace", modelName + "/StatusLog", Position=[300, 90, 410, 120]);
    set_param(modelName + "/DataLog", "VariableName", "rxData", "SaveFormat", "Array");
    set_param(modelName + "/StatusLog", "VariableName", "rxStatus", "SaveFormat", "Array");
    add_line(modelName, "RX/1", "DataLog/1");
    add_line(modelName, "RX/2", "StatusLog/1");

    simOut = sim(modelName);
    data = simOut.rxData(:, end);
    status = simOut.rxStatus(end);
end

function name = uniqueModelName(prefix)
    name = string(prefix) + string(randi(1e6));
end
