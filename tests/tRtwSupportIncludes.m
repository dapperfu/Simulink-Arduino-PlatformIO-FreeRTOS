classdef tRtwSupportIncludes < matlab.unittest.TestCase
    % Tests for MATLAB ERT headers used by generated PlatformIO builds.

    methods (TestClassSetup)
        function addRepoToPath(testCase)
            testsFolder = fileparts(mfilename("fullpath"));
            repoRoot = fileparts(testsFolder);
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture(repoRoot));
        end
    end

    methods (Test)
        function expandsMakeTokensAndAddsSimulinkInclude(testCase)
            includeFlags = piofrtos.collectIncludeFlags([
                "$(MATLAB_ROOT)/simulink/include"
                "$(START_DIR)/shared"
                "$(UNKNOWN)/skip"
                ], MatlabRoot="C:/MATLAB/R2025b", StartDir="C:/proj/examples");

            flagText = join(includeFlags, newline);
            testCase.verifyEqual(includeFlags(1), "-I.");
            testCase.verifySubstring(flagText, "-I""C:/MATLAB/R2025b/simulink/include""");
            testCase.verifySubstring(flagText, "-I""C:/proj/examples/shared""");
            testCase.verifySubstring(flagText, "-I""C:/MATLAB/R2025b/extern/include""");
            testCase.verifyFalse(contains(flagText, "$(MATLAB_ROOT)"));
            testCase.verifyFalse(contains(flagText, "$(START_DIR)"));
            testCase.verifyFalse(contains(flagText, "$(UNKNOWN)"));
        end

        function copiesContinuousAndSolverHeaders(testCase)
            fixture = testCase.applyFixture(matlab.unittest.fixtures.TemporaryFolderFixture);
            copiedFiles = piofrtos.copyRtwSupportHeaders(fixture.Folder);

            continuousHeader = fullfile(fixture.Folder, "rtw_continuous.h");
            solverHeader = fullfile(fixture.Folder, "rtw_solver.h");
            testCase.verifyTrue(isfile(continuousHeader));
            testCase.verifyTrue(isfile(solverHeader));
            testCase.verifyTrue(any(copiedFiles == string(continuousHeader)));
            testCase.verifyTrue(any(copiedFiles == string(solverHeader)));

            continuousText = string(fileread(continuousHeader));
            solverText = string(fileread(solverHeader));
            testCase.verifySubstring(continuousText, "rtwtypes.h");
            testCase.verifySubstring(solverText, "rtw_continuous.h");
        end
    end
end
