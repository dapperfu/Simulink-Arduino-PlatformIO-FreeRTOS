classdef tLocatePlatformio < matlab.unittest.TestCase
    %TLOCATEPLATFORMIO - Locks locating the host PlatformIO CLI command string.
    %   Covers piofrtos.locatePlatformio with MustExist false/true, including the
    %   piofrtos:PlatformIONotFound error when PIO_CMD is cleared and no CLI is found.
    %   PathFixture adds the repo root. Failure means discovery or error identity drifted.
    %
    %   Syntax:
    %       result = runtests("tLocatePlatformio")
    %
    %   Inputs:
    %       none
    %
    %   Outputs:
    %       none. Test methods pass, fail, or throw matlab.unittest results.
    %
    %   Example:
    %       result = runtests("tLocatePlatformio");
    %
    %   Other m-files required: piofrtos.locatePlatformio
    %   Subfunctions: restorePioCmd
    %   MAT-files required: none
    %
    %   See also: TEMITPLATFORMIOINI, PIOFRTOS.LOCATEPLATFORMIO

    %   Author: Frey, Jed
    %   28-Sep-2026; Last revision: 28-Sep-2026

    methods (TestClassSetup)
        function addRepoToPath(testCase)
        %ADDREPOTOPATH - Adds the repository root to the MATLAB path for the class.
        %   Resolves the repo root from this test file location and applies PathFixture so
        %   piofrtos.locatePlatformio resolves during the suite.
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
        %       runtests("tLocatePlatformio", "ProcedureName", "addRepoToPath");
        %
        %   See also: TLOCATEPLATFORMIO
            testsFolder = fileparts(mfilename("fullpath"));
            repoRoot = fileparts(testsFolder);
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture(repoRoot));
        end
    end

    methods (Test)
        function returnsStringWithoutThrowing(testCase)
        %RETURNSSTRINGWITHOUTTHROWING - MustExist=false returns a 1-by-1 string.
        %   Calls locatePlatformio(MustExist=false) and verifies class string and size
        %   [1, 1] without requiring PlatformIO to be installed.
        %
        %   Syntax:
        %       returnsStringWithoutThrowing(testCase)
        %
        %   Inputs:
        %       testCase - matlab.unittest.TestCase instance supplied by the runner.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       runtests("tLocatePlatformio", ...
        %           "ProcedureName", "returnsStringWithoutThrowing");
        %
        %   See also: TLOCATEPLATFORMIO, PIOFRTOS.LOCATEPLATFORMIO
            pioCmd = piofrtos.locatePlatformio(MustExist=false);
            testCase.verifyClass(pioCmd, "string");
            testCase.verifyEqual(size(pioCmd), [1, 1]);
        end

        function mustExistThrowsWhenMissing(testCase)
        %MUSTEXISTTHROWSWHENMISSING - MustExist=true errors when PlatformIO is missing.
        %   Clears PIO_CMD, assumes fail if a CLI is still discoverable, otherwise expects
        %   error identifier piofrtos:PlatformIONotFound. Restores PIO_CMD via onCleanup.
        %
        %   Syntax:
        %       mustExistThrowsWhenMissing(testCase)
        %
        %   Inputs:
        %       testCase - matlab.unittest.TestCase instance supplied by the runner.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       runtests("tLocatePlatformio", ...
        %           "ProcedureName", "mustExistThrowsWhenMissing");
        %
        %   See also: TLOCATEPLATFORMIO, RESTOREPIOCMD
            previous = getenv("PIO_CMD");
            restore = onCleanup(@() restorePioCmd(previous));
            setenv("PIO_CMD", "");

            if strlength(piofrtos.locatePlatformio(MustExist=false)) > 0
                testCase.assumeFail("PlatformIO is installed; cannot test the missing-CLI error.");
            end

            testCase.verifyError(@() piofrtos.locatePlatformio(MustExist=true), ...
                "piofrtos:PlatformIONotFound");
        end
    end
end

function restorePioCmd(previous)
%RESTOREPIOCMD - Restores the PIO_CMD environment variable after a missing-CLI test.
%   Sets PIO_CMD to previous when nonempty; otherwise clears it to an empty string so
%   the process environment matches the pre-test state.
%
%   Syntax:
%       restorePioCmd(previous)
%
%   Inputs:
%       previous - char vector from getenv("PIO_CMD") captured before the test mutated it.
%
%   Outputs:
%       none
%
%   Example:
%       restorePioCmd(previous);
%
%   See also: TLOCATEPLATFORMIO
    if isempty(previous)
        setenv("PIO_CMD", "");
    else
        setenv("PIO_CMD", previous);
    end
end
