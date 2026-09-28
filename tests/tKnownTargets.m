classdef tKnownTargets < matlab.unittest.TestCase
    % Tests for known-good PlatformIO board, platform, and framework choices.

    methods (TestClassSetup)
        function addRepoToPath(testCase)
            testsFolder = fileparts(mfilename("fullpath"));
            repoRoot = fileparts(testsFolder);
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture(repoRoot));
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture(fullfile(repoRoot, "matlab")));
        end
    end

    methods (Test)
        function listsUnoAndNanoOnAtmelavrArduino(testCase)
            targets = piofrtos.listKnownTargets();
            displayNames = [targets.DisplayName];
            testCase.verifyEqual(displayNames, ["Arduino Uno", "Arduino Nano"]);
            testCase.verifyTrue(all([targets.Platform] == "atmelavr"));
            testCase.verifyTrue(all([targets.Framework] == "arduino"));
            testCase.verifyEqual([targets.Board], ["uno", "nanoatmega328"]);
        end

        function resolvesDisplayNameAndBoardId(testCase)
            [unoTarget, unoKnown] = piofrtos.resolveKnownTarget("Arduino Uno");
            testCase.verifyTrue(unoKnown);
            testCase.verifyEqual(unoTarget.Board, "uno");
            testCase.verifyEqual(unoTarget.Platform, "atmelavr");

            [nanoTarget, nanoKnown] = piofrtos.resolveKnownTarget("nanoatmega328");
            testCase.verifyTrue(nanoKnown);
            testCase.verifyEqual(nanoTarget.DisplayName, "Arduino Nano");

            [unknownTarget, unknownKnown] = piofrtos.resolveKnownTarget("esp32dev");
            testCase.verifyFalse(unknownKnown);
            testCase.verifyEqual(unknownTarget.Board, "esp32dev");
        end

        function nanoBoardMapIncludesExtraAnalogPins(testCase)
            info = arduinopio.boards.getBoard("Arduino Nano");
            testCase.verifyEqual(info.Name, "nano");
            testCase.verifyEqual(info.AnalogPins, 0:7);
            testCase.verifyTrue(info.Implemented);
        end
    end
end
