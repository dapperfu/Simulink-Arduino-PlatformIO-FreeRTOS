classdef tCanBlocks < matlab.unittest.TestCase
    %TCANBLOCKS - Host simulation tests for MCP2515 CAN Transmit and Receive blocks.
    %   Covers CanReceive idle outputs, CanTransmit uint8 payload simulation,
    %   knownLibDeps MCP2515 entry, and validateCanIdentifier range checks. Fixtures add
    %   matlab path. Failure means host idle behavior, lib deps, or ID validation drifted.
    %
    %   Syntax:
    %       result = runtests("tCanBlocks")
    %
    %   Inputs:
    %       none
    %
    %   Outputs:
    %       none. Test methods pass, fail, or throw matlab.unittest results.
    %
    %   Example:
    %       result = runtests("tCanBlocks");
    %
    %   Other m-files required: arduinopio.blocks.common.CanReceive,
    %       arduinopio.blocks.common.CanTransmit, arduinopio.knownLibDeps,
    %       arduinopio.validateCanIdentifier
    %   Subfunctions: uniqueModelName
    %   MAT-files required: none
    %
    %   See also: TCOMMONIOSFUNCTIONS, ARDUINOPIO.VALIDATECANIDENTIFIER

    %   Author: Frey, Jed
    %   28-Sep-2026; Last revision: 28-Sep-2026

    methods (TestClassSetup)
        function addRepoToPath(testCase)
        %ADDREPOTOPATH - Adds the repository and matlab package paths for the class.
        %   Applies PathFixture so CAN System objects and validation helpers resolve
        %   during host simulation.
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
        %       runtests("tCanBlocks", "ProcedureName", "addRepoToPath");
        %
        %   See also: TCANBLOCKS
            testsFolder = fileparts(mfilename("fullpath"));
            repoRoot = fileparts(testsFolder);
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture(repoRoot));
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture(fullfile(repoRoot, "matlab")));
        end
    end

    methods (Test)
        function receiveIsIdleOnHost(testCase)
        %RECEIVEISIDLEONHOST - CanReceive stays idle with zero id/data/len on host.
        %   Simulates CanReceive under interpreted execution and verifies last samples:
        %   canId 0, eight uint8 zeros, length 0, and status false.
        %
        %   Syntax:
        %       receiveIsIdleOnHost(testCase)
        %
        %   Inputs:
        %       testCase - matlab.unittest.TestCase instance supplied by the runner.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       runtests("tCanBlocks", "ProcedureName", "receiveIsIdleOnHost");
        %
        %   See also: TCANBLOCKS, ARDUINOPIO.BLOCKS.COMMON.CANRECEIVE
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
        %TRANSMITACCEPTSUINT8PAYLOAD - CanTransmit accepts an 8-byte uint8 payload.
        %   Drives CanTransmit from Constant uint8(1:8) under interpreted execution and
        %   verifies sim completes without error.
        %
        %   Syntax:
        %       transmitAcceptsUint8Payload(testCase)
        %
        %   Inputs:
        %       testCase - matlab.unittest.TestCase instance supplied by the runner.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       runtests("tCanBlocks", "ProcedureName", "transmitAcceptsUint8Payload");
        %
        %   See also: TCANBLOCKS, ARDUINOPIO.BLOCKS.COMMON.CANTRANSMIT
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
        %KNOWNLIBDEPSINCLUDESMCP2515 - knownLibDeps lists MCP2515 define and library.
        %   Asserts ARDUINOPIO_NEED_MCP2515 appears among Define fields and
        %   autowp/autowp-mcp2515 among LibDep fields.
        %
        %   Syntax:
        %       knownLibDepsIncludesMcp2515(testCase)
        %
        %   Inputs:
        %       testCase - matlab.unittest.TestCase instance supplied by the runner.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       runtests("tCanBlocks", "ProcedureName", "knownLibDepsIncludesMcp2515");
        %
        %   See also: TCANBLOCKS, ARDUINOPIO.KNOWNLIBDEPS
            deps = arduinopio.knownLibDeps();
            defines = string({deps.Define});
            libraries = string({deps.LibDep});
            testCase.verifyTrue(any(defines == "ARDUINOPIO_NEED_MCP2515"));
            testCase.verifyTrue(any(libraries == "autowp/autowp-mcp2515"));
        end

        function rejectsOversizedStandardId(testCase)
        %REJECTSOVERSIZEDSTANDARDID - Standard CAN id 2048 errors with arduinopio:CanId.
        %   Calls validateCanIdentifier(2048, false, "MessageId") and expects error
        %   identifier arduinopio:CanId.
        %
        %   Syntax:
        %       rejectsOversizedStandardId(testCase)
        %
        %   Inputs:
        %       testCase - matlab.unittest.TestCase instance supplied by the runner.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       runtests("tCanBlocks", "ProcedureName", "rejectsOversizedStandardId");
        %
        %   See also: TCANBLOCKS, ARDUINOPIO.VALIDATECANIDENTIFIER
            testCase.verifyError(@() arduinopio.validateCanIdentifier(2048, false, "MessageId"), ...
                "arduinopio:CanId");
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
%       name = uniqueModelName("canRx");
%
%   See also: TCANBLOCKS
    name = string(prefix) + string(randi(1e6));
end
