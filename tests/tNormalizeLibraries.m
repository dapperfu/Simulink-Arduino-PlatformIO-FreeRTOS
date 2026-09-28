classdef tNormalizeLibraries < matlab.unittest.TestCase
    % Tests for splitting extra PlatformIO library entries.

    methods (TestClassSetup)
        function addRepoToPath(testCase)
            testsFolder = fileparts(mfilename("fullpath"));
            repoRoot = fileparts(testsFolder);
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture(repoRoot));
        end
    end

    methods (Test)
        function splitsCommaAndSemicolonLists(testCase)
            libraries = piofrtos.normalizeLibraries("feilipu/FreeRTOS, bblanchon/ArduinoJson; knolleary/PubSubClient");
            testCase.verifyEqual(libraries(:), [ ...
                "feilipu/FreeRTOS"; ...
                "bblanchon/ArduinoJson"; ...
                "knolleary/PubSubClient"]);
        end

        function emptyStringReturnsEmpty(testCase)
            libraries = piofrtos.normalizeLibraries("   ");
            testCase.verifyEmpty(libraries);
        end
    end
end
