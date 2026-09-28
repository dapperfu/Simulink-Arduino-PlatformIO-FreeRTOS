classdef tRtwSupportIncludes < matlab.unittest.TestCase
    %TRTWSUPPORTINCLUDES - Locks ERT include-flag expansion and RTW support header copy.
    %   Covers piofrtos.collectIncludeFlags and piofrtos.copyRtwSupportHeaders used by
    %   PlatformIO builds. PathFixture adds the repo root. Failures mean make tokens are
    %   not expanded, required Simulink includes are missing, or continuous/solver headers
    %   are not copied into the build folder.
    %
    %   Syntax:
    %       result = runtests("tRtwSupportIncludes")
    %
    %   Inputs:
    %       none
    %
    %   Outputs:
    %       none. Test methods pass, fail, or throw matlab.unittest results.
    %
    %   Example:
    %       result = runtests("tRtwSupportIncludes");
    %
    %   Other m-files required: piofrtos.collectIncludeFlags, piofrtos.copyRtwSupportHeaders
    %   Subfunctions: none
    %   MAT-files required: none
    %
    %   See also: TGENERATETARGETFILES, PIOFRTOS.COLLECTINCLUDEFLAGS

    %   Author: Frey, Jed
    %   28-Sep-2026; Last revision: 28-Sep-2026

    methods (TestClassSetup)
        function addRepoToPath(testCase)
        %ADDREPOTOPATH - Adds the repository root to the MATLAB path for the class.
        %   Resolves the repo root from this test file location and applies PathFixture so
        %   piofrtos package functions resolve during the suite.
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
        %       runtests("tRtwSupportIncludes", "ProcedureName", "addRepoToPath");
        %
        %   See also: TRTWSUPPORTINCLUDES
            testsFolder = fileparts(mfilename("fullpath"));
            repoRoot = fileparts(testsFolder);
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture(repoRoot));
        end
    end

    methods (Test)
        function expandsMakeTokensAndAddsSimulinkInclude(testCase)
        %EXPANDSMAKETOKENSANDADDSSIMULINKINCLUDE - Expands make tokens into -I flags.
        %   Passes $(MATLAB_ROOT), $(START_DIR), and unknown tokens with MatlabRoot and
        %   StartDir name-values. Expects -I., quoted expanded paths, extern/include, and
        %   that unresolved tokens are dropped from the joined flag text.
        %
        %   Syntax:
        %       expandsMakeTokensAndAddsSimulinkInclude(testCase)
        %
        %   Inputs:
        %       testCase - matlab.unittest.TestCase instance supplied by the runner.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       runtests("tRtwSupportIncludes", ...
        %           "ProcedureName", "expandsMakeTokensAndAddsSimulinkInclude");
        %
        %   See also: TRTWSUPPORTINCLUDES, PIOFRTOS.COLLECTINCLUDEFLAGS
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
        %COPIESCONTINUOUSANDSOLVERHEADERS - Copies rtw_continuous.h and rtw_solver.h.
        %   Uses TemporaryFolderFixture and piofrtos.copyRtwSupportHeaders. Asserts both
        %   files exist, appear in the returned list, and contain expected include text
        %   (rtwtypes.h and rtw_continuous.h respectively).
        %
        %   Syntax:
        %       copiesContinuousAndSolverHeaders(testCase)
        %
        %   Inputs:
        %       testCase - matlab.unittest.TestCase instance supplied by the runner.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       runtests("tRtwSupportIncludes", ...
        %           "ProcedureName", "copiesContinuousAndSolverHeaders");
        %
        %   See also: TRTWSUPPORTINCLUDES, PIOFRTOS.COPYRTWSUPPORTHEADERS
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
