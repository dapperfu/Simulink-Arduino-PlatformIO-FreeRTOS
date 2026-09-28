classdef tGenerateTargetFiles < matlab.unittest.TestCase
    %TGENERATETARGETFILES - Locks TLC and TMF generation from the option table.
    %   Covers piofrtos.generateTargetFiles writing piofrtos.tlc and piofrtos.tmf into a
    %   temporary folder. PathFixture adds the repo root. Failure means shared target
    %   options, callbacks, or makefile hooks are missing or incorrect in generated text.
    %
    %   Syntax:
    %       result = runtests("tGenerateTargetFiles")
    %
    %   Inputs:
    %       none
    %
    %   Outputs:
    %       none. Test methods pass, fail, or throw matlab.unittest results.
    %
    %   Example:
    %       result = runtests("tGenerateTargetFiles");
    %
    %   Other m-files required: piofrtos.generateTargetFiles
    %   Subfunctions: none
    %   MAT-files required: none
    %
    %   See also: TGETDEFAULTOPTIONS, PIOFRTOS.GENERATETARGETFILES

    %   Author: Frey, Jed
    %   28-Sep-2026; Last revision: 28-Sep-2026

    methods (TestClassSetup)
        function addRepoToPath(testCase)
        %ADDREPOTOPATH - Adds the repository root to the MATLAB path for the class.
        %   Resolves the repo root from this test file location and applies PathFixture so
        %   piofrtos.generateTargetFiles resolves during the suite.
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
        %       runtests("tGenerateTargetFiles", "ProcedureName", "addRepoToPath");
        %
        %   See also: TGENERATETARGETFILES
            testsFolder = fileparts(mfilename("fullpath"));
            repoRoot = fileparts(testsFolder);
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture(repoRoot));
        end
    end

    methods (Test)
        function writesTlcAndTmfWithSharedOptions(testCase)
        %WRITESTLCANDTMFWITHSHAREDOPTIONS - Emits TLC/TMF with shared PlatformIO options.
        %   Generates two files in a temporary folder and asserts TLC title, ERT settings,
        %   PioBoard/PioExtraLibraries popups, syncKnownTarget callback, Uno/Nano only
        %   (no esp32dev), and TMF tokens for PIO run/upload and pio_cmd.mk.
        %
        %   Syntax:
        %       writesTlcAndTmfWithSharedOptions(testCase)
        %
        %   Inputs:
        %       testCase - matlab.unittest.TestCase instance supplied by the runner.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       runtests("tGenerateTargetFiles", ...
        %           "ProcedureName", "writesTlcAndTmfWithSharedOptions");
        %
        %   See also: TGENERATETARGETFILES, PIOFRTOS.GENERATETARGETFILES
            fixture = testCase.applyFixture(matlab.unittest.fixtures.TemporaryFolderFixture);
            generatedFiles = piofrtos.generateTargetFiles(fixture.Folder);
            testCase.verifyEqual(numel(generatedFiles), 2);

            tlcText = string(fileread(fullfile(fixture.Folder, "piofrtos.tlc")));
            tmfText = string(fileread(fullfile(fixture.Folder, "piofrtos.tmf")));

            testCase.verifySubstring(tlcText, "SYSTLC: Arduino FreeRTOS (PlatformIO)");
            testCase.verifySubstring(tlcText, "TMF: piofrtos.tmf");
            testCase.verifySubstring(tlcText, "MAKE: make_rtw");
            testCase.verifySubstring(tlcText, "%assign CodeFormat = ""Embedded-C""");
            testCase.verifySubstring(tlcText, "%assign RateBasedStepFcn = 1");
            testCase.verifySubstring(tlcText, "rtwgensettings.DerivedFrom    = 'ert.tlc'");
            testCase.verifySubstring(tlcText, "piofrtos.selectCallback");
            testCase.verifySubstring(tlcText, "PioBoard");
            testCase.verifySubstring(tlcText, "PioExtraLibraries");
            testCase.verifySubstring(tlcText, "type           = 'Popup'");
            testCase.verifySubstring(tlcText, "popupstrings   = 'Arduino Uno|Arduino Nano'");
            testCase.verifySubstring(tlcText, "popupstrings   = 'atmelavr'");
            testCase.verifySubstring(tlcText, "popupstrings   = 'arduino'");
            testCase.verifySubstring(tlcText, "piofrtos.syncKnownTarget(hDlg, hSrc)");
            testCase.verifyFalse(contains(tlcText, "esp32dev"));

            testCase.verifySubstring(tmfText, "SYS_TARGET_FILE = piofrtos.tlc");
            testCase.verifySubstring(tmfText, "PIO_BOARD               = |>PIO_BOARD<|");
            testCase.verifySubstring(tmfText, "DEFINES_OTHER           = |>DEFINES_OTHER<|");
            testCase.verifySubstring(tmfText, "DEFINES_CUSTOM          = |>DEFINES_CUSTOM<|");
            testCase.verifySubstring(tmfText, "COMPILE_FLAGS_OTHER     = |>COMPILE_FLAGS_OTHER<|");
            testCase.verifySubstring(tmfText, ...
                "MODEL_HAS_DYNAMICALLY_LOADED_SFCNS = |>MODEL_HAS_DYNAMICALLY_LOADED_SFCNS<|");
            testCase.verifySubstring(tmfText, """$(PIO_CMD)"" run --project-dir .");
            testCase.verifySubstring(tmfText, "-t upload");
            testCase.verifySubstring(tmfText, "-include pio_cmd.mk");
        end
    end
end
