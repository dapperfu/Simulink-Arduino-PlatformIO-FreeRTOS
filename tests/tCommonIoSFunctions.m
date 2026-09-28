classdef tCommonIoSFunctions < matlab.unittest.TestCase
    %TCOMMONIOSFUNCTIONS - Simulation tests for Digital, Analog, and Serial S-functions.
    %   Host-simulates Level-2 MATLAB S-functions for digital/analog IO and serial
    %   receive/transmit. Fixtures add matlab and sfcn paths. Local helpers build short
    %   models. Failure means simulation values or idle serial behavior drifted.
    %
    %   Syntax:
    %       result = runtests("tCommonIoSFunctions")
    %
    %   Inputs:
    %       none
    %
    %   Outputs:
    %       none. Test methods pass, fail, or throw matlab.unittest results.
    %
    %   Example:
    %       result = runtests("tCommonIoSFunctions");
    %
    %   Other m-files required: arduinopio_digital_input, arduinopio_analog_input,
    %       arduinopio_digital_output, arduinopio_analog_output,
    %       arduinopio_serial_receive, arduinopio_serial_transmit
    %   Subfunctions: simulateSourceBlock, simulateSerialReceive, uniqueModelName
    %   MAT-files required: none
    %
    %   See also: TPINPULL, TDIGITALIOMETHODS

    %   Author: Frey, Jed
    %   28-Sep-2026; Last revision: 28-Sep-2026

    methods (TestClassSetup)
        function addRepoToPath(testCase)
        %ADDREPOTOPATH - Adds repo, matlab, and sfcn paths for the class.
        %   Applies PathFixture so common IO Level-2 MATLAB S-functions resolve during
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
        %       runtests("tCommonIoSFunctions", "ProcedureName", "addRepoToPath");
        %
        %   See also: TCOMMONIOSFUNCTIONS
            testsFolder = fileparts(mfilename("fullpath"));
            repoRoot = fileparts(testsFolder);
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture(repoRoot));
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture(fullfile(repoRoot, "matlab")));
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture(fullfile(repoRoot, "sfcn")));
        end
    end

    methods (Test)
        function digitalInputUsesSimulationValue(testCase)
        %DIGITALINPUTUSESSIMULATIONVALUE - Digital input outputs SimValue 1.
        %   Simulates arduinopio_digital_input with parameters "2, 0, 0.01, 1" and
        %   verifies the last logged sample is true.
        %
        %   Syntax:
        %       digitalInputUsesSimulationValue(testCase)
        %
        %   Inputs:
        %       testCase - matlab.unittest.TestCase instance supplied by the runner.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       runtests("tCommonIoSFunctions", ...
        %           "ProcedureName", "digitalInputUsesSimulationValue");
        %
        %   See also: TCOMMONIOSFUNCTIONS, SIMULATESOURCEBLOCK
            output = simulateSourceBlock(testCase, "arduinopio_digital_input", "2, 0, 0.01, 1");
            testCase.verifyTrue(logical(output));
        end

        function analogInputUsesSimulationCounts(testCase)
        %ANALOGINPUTUSESSIMULATIONCOUNTS - Analog input outputs SimValue counts 512.
        %   Simulates arduinopio_analog_input with parameters "0, 0.01, 512" and verifies
        %   the last sample equals uint16(512).
        %
        %   Syntax:
        %       analogInputUsesSimulationCounts(testCase)
        %
        %   Inputs:
        %       testCase - matlab.unittest.TestCase instance supplied by the runner.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       runtests("tCommonIoSFunctions", ...
        %           "ProcedureName", "analogInputUsesSimulationCounts");
        %
        %   See also: TCOMMONIOSFUNCTIONS, SIMULATESOURCEBLOCK
            output = simulateSourceBlock(testCase, "arduinopio_analog_input", "0, 0.01, 512");
            testCase.verifyEqual(output, uint16(512));
        end

        function serialReceiveReturnsIdleOnHost(testCase)
        %SERIALRECEIVERETURNSIDLEONHOST - Serial receive is idle with zero data on host.
        %   Simulates arduinopio_serial_receive and verifies two uint8 zeros and status
        %   false on the last sample.
        %
        %   Syntax:
        %       serialReceiveReturnsIdleOnHost(testCase)
        %
        %   Inputs:
        %       testCase - matlab.unittest.TestCase instance supplied by the runner.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       runtests("tCommonIoSFunctions", ...
        %           "ProcedureName", "serialReceiveReturnsIdleOnHost");
        %
        %   See also: TCOMMONIOSFUNCTIONS, SIMULATESERIALRECEIVE
            [data, status] = simulateSerialReceive(testCase);
            testCase.verifyEqual(data, zeros(2, 1, "uint8"));
            testCase.verifyFalse(logical(status));
        end

        function digitalAndAnalogOutputsSimulate(testCase)
        %DIGITALANDANALOGOUTPUTSSIMULATE - Digital and analog outputs simulate together.
        %   Builds a model driving arduinopio_digital_output (pin 13) and
        %   arduinopio_analog_output (pin 5) from constants and verifies sim completes.
        %
        %   Syntax:
        %       digitalAndAnalogOutputsSimulate(testCase)
        %
        %   Inputs:
        %       testCase - matlab.unittest.TestCase instance supplied by the runner.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       runtests("tCommonIoSFunctions", ...
        %           "ProcedureName", "digitalAndAnalogOutputsSimulate");
        %
        %   See also: TCOMMONIOSFUNCTIONS
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
        %SERIALTRANSMITACCEPTSUINT8 - Serial transmit accepts a uint8 payload on host.
        %   Drives arduinopio_serial_transmit (port 0, 9600) from Constant uint8(65) and
        %   verifies sim completes.
        %
        %   Syntax:
        %       serialTransmitAcceptsUint8(testCase)
        %
        %   Inputs:
        %       testCase - matlab.unittest.TestCase instance supplied by the runner.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       runtests("tCommonIoSFunctions", ...
        %           "ProcedureName", "serialTransmitAcceptsUint8");
        %
        %   See also: TCOMMONIOSFUNCTIONS
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
%SIMULATESOURCEBLOCK - Host-simulates a source S-function and returns the last sample.
%   Builds a short fixed-step model with the named Level-2 MATLAB S-Function, logs
%   output to the workspace, and returns the final logged row.
%
%   Syntax:
%       output = simulateSourceBlock(testCase, sfcnName, parameters)
%
%   Inputs:
%       testCase - matlab.unittest.TestCase instance for assertTrue on load.
%       sfcnName - char or string FunctionName for the S-Function block.
%       parameters - char or string S-Function Parameters vector string.
%
%   Outputs:
%       output - last logged sample from the source block.
%
%   Example:
%       output = simulateSourceBlock(testCase, "arduinopio_digital_input", "2, 0, 0.01, 1");
%
%   See also: TCOMMONIOSFUNCTIONS
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
%SIMULATESERIALRECEIVE - Host-simulates serial receive and returns last data and status.
%   Builds a short fixed-step model with arduinopio_serial_receive parameters
%   "0, 9600, 2, 0.01" and logs both output ports.
%
%   Syntax:
%       [data, status] = simulateSerialReceive(testCase)
%
%   Inputs:
%       testCase - matlab.unittest.TestCase instance for assertTrue on load.
%
%   Outputs:
%       data - last data column from the receive block.
%       status - last status sample from the receive block.
%
%   Example:
%       [data, status] = simulateSerialReceive(testCase);
%
%   See also: TCOMMONIOSFUNCTIONS
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
%       name = uniqueModelName("ioSrc");
%
%   See also: TCOMMONIOSFUNCTIONS
    name = string(prefix) + string(randi(1e6));
end
