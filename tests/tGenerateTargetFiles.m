classdef tGenerateTargetFiles < matlab.unittest.TestCase
    % Tests for TLC and TMF generation from the option table.

    methods (TestClassSetup)
        function addRepoToPath(testCase)
            testsFolder = fileparts(mfilename("fullpath"));
            repoRoot = fileparts(testsFolder);
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture(repoRoot));
        end
    end

    methods (Test)
        function writesTlcAndTmfWithSharedOptions(testCase)
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
