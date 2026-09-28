classdef tKnownTargets < matlab.unittest.TestCase
    %TKNOWNTARGETS - Locks known-good PlatformIO board, platform, and framework choices.
    %   Covers piofrtos.listKnownTargets, resolveKnownTarget, and arduinopio.boards.getBoard
    %   for Uno and Nano. Fixtures add repo and matlab paths. Failure means the known-target
    %   table or board map drifted from the supported AVR Arduino set.
    %
    %   Syntax:
    %       result = runtests("tKnownTargets")
    %
    %   Inputs:
    %       none
    %
    %   Outputs:
    %       none. Test methods pass, fail, or throw matlab.unittest results.
    %
    %   Example:
    %       result = runtests("tKnownTargets");
    %
    %   Other m-files required: piofrtos.listKnownTargets, piofrtos.resolveKnownTarget,
    %       arduinopio.boards.getBoard
    %   Subfunctions: none
    %   MAT-files required: none
    %
    %   See also: TEMITPLATFORMIOINI, PIOFRTOS.LISTKNOWNTARGETS

    %   Author: Frey, Jed
    %   28-Sep-2026; Last revision: 28-Sep-2026

    methods (TestClassSetup)
        function addRepoToPath(testCase)
        %ADDREPOTOPATH - Adds the repository and matlab package paths for the class.
        %   Applies PathFixture for the repo root and matlab folder so piofrtos and
        %   arduinopio.boards helpers resolve during the suite.
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
        %       runtests("tKnownTargets", "ProcedureName", "addRepoToPath");
        %
        %   See also: TKNOWNTARGETS
            testsFolder = fileparts(mfilename("fullpath"));
            repoRoot = fileparts(testsFolder);
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture(repoRoot));
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture(fullfile(repoRoot, "matlab")));
        end
    end

    methods (Test)
        function listsUnoAndNanoOnAtmelavrArduino(testCase)
        %LISTSUNOANDNANOONATMELAVRARDUINO - Known list is Uno and Nano on AVR Arduino.
        %   Calls listKnownTargets and verifies DisplayName Arduino Uno/Nano, Platform
        %   atmelavr, Framework arduino, and Board ids uno and nanoatmega328.
        %
        %   Syntax:
        %       listsUnoAndNanoOnAtmelavrArduino(testCase)
        %
        %   Inputs:
        %       testCase - matlab.unittest.TestCase instance supplied by the runner.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       runtests("tKnownTargets", ...
        %           "ProcedureName", "listsUnoAndNanoOnAtmelavrArduino");
        %
        %   See also: TKNOWNTARGETS, PIOFRTOS.LISTKNOWNTARGETS
            targets = piofrtos.listKnownTargets();
            displayNames = [targets.DisplayName];
            testCase.verifyEqual(displayNames, ["Arduino Uno", "Arduino Nano"]);
            testCase.verifyTrue(all([targets.Platform] == "atmelavr"));
            testCase.verifyTrue(all([targets.Framework] == "arduino"));
            testCase.verifyEqual([targets.Board], ["uno", "nanoatmega328"]);
        end

        function resolvesDisplayNameAndBoardId(testCase)
        %RESOLVESDISPLAYNAMEANDBOARDID - resolveKnownTarget maps names and ids.
        %   Resolves "Arduino Uno" to board uno/atmelavr, "nanoatmega328" to Arduino Nano,
        %   and unknown "esp32dev" with known=false while preserving Board "esp32dev".
        %
        %   Syntax:
        %       resolvesDisplayNameAndBoardId(testCase)
        %
        %   Inputs:
        %       testCase - matlab.unittest.TestCase instance supplied by the runner.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       runtests("tKnownTargets", ...
        %           "ProcedureName", "resolvesDisplayNameAndBoardId");
        %
        %   See also: TKNOWNTARGETS, PIOFRTOS.RESOLVEKNOWNTARGET
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
        %NANOBOARDMAPINCLUDESEXTRAANALOGPINS - Nano board info lists analog pins 0:7.
        %   Calls arduinopio.boards.getBoard("Arduino Nano") and verifies Name "nano",
        %   AnalogPins 0:7, and Implemented true.
        %
        %   Syntax:
        %       nanoBoardMapIncludesExtraAnalogPins(testCase)
        %
        %   Inputs:
        %       testCase - matlab.unittest.TestCase instance supplied by the runner.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       runtests("tKnownTargets", ...
        %           "ProcedureName", "nanoBoardMapIncludesExtraAnalogPins");
        %
        %   See also: TKNOWNTARGETS, ARDUINOPIO.BOARDS.GETBOARD
            info = arduinopio.boards.getBoard("Arduino Nano");
            testCase.verifyEqual(info.Name, "nano");
            testCase.verifyEqual(info.AnalogPins, 0:7);
            testCase.verifyTrue(info.Implemented);
        end
    end
end
