classdef tLocatePlatformio < matlab.unittest.TestCase
    % Tests for locating the host PlatformIO CLI.

    methods (TestClassSetup)
        function addRepoToPath(testCase)
            testsFolder = fileparts(mfilename("fullpath"));
            repoRoot = fileparts(testsFolder);
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture(repoRoot));
        end
    end

    methods (Test)
        function returnsStringWithoutThrowing(testCase)
            pioCmd = piofrtos.locatePlatformio(MustExist=false);
            testCase.verifyClass(pioCmd, "string");
            testCase.verifyEqual(size(pioCmd), [1, 1]);
        end

        function mustExistThrowsWhenMissing(testCase)
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
    if isempty(previous)
        setenv("PIO_CMD", "");
    else
        setenv("PIO_CMD", previous);
    end
end
