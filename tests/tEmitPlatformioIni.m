classdef tEmitPlatformioIni < matlab.unittest.TestCase
    % Tests for platformio.ini generation.

    methods (TestClassSetup)
        function addRepoToPath(testCase)
            testsFolder = fileparts(mfilename("fullpath"));
            repoRoot = fileparts(testsFolder);
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture(repoRoot));
        end
    end

    methods (Test)
        function writesBoardPlatformAndLibraries(testCase)
            fixture = testCase.applyFixture(matlab.unittest.fixtures.TemporaryFolderFixture);
            iniPath = fullfile(fixture.Folder, "platformio.ini");

            piofrtos.emitPlatformioIni(iniPath, ...
                ModelName="demoModel", ...
                Platform="atmelavr", ...
                Board="uno", ...
                Framework="arduino", ...
                ExtraLibraries="feilipu/FreeRTOS, bblanchon/ArduinoJson", ...
                MonitorSpeed="9600", ...
                IncludeFlags=["-I.", "-Isrc"], ...
                Defines="-DNUMST=2");

            text = readText(iniPath);
            testCase.verifySubstring(text, "[env:uno]");
            testCase.verifySubstring(text, "platform = atmelavr");
            testCase.verifySubstring(text, "board = uno");
            testCase.verifySubstring(text, "framework = arduino");
            testCase.verifySubstring(text, "monitor_speed = 9600");
            testCase.verifySubstring(text, "feilipu/FreeRTOS");
            testCase.verifySubstring(text, "bblanchon/ArduinoJson");
            testCase.verifySubstring(text, "-DMODEL=demoModel");
            testCase.verifySubstring(text, "-<ert_main.c>");
            testCase.verifySubstring(text, "src_dir = .");
        end

        function omitsLibDepsWhenEmpty(testCase)
            fixture = testCase.applyFixture(matlab.unittest.fixtures.TemporaryFolderFixture);
            iniPath = fullfile(fixture.Folder, "platformio.ini");

            piofrtos.emitPlatformioIni(iniPath, ModelName="demoModel");
            text = readText(iniPath);
            testCase.verifyFalse(contains(text, "lib_deps"));
            testCase.verifySubstring(text, "[env:uno]");
            testCase.verifySubstring(text, "platform = atmelavr");
            testCase.verifySubstring(text, "board = uno");
        end

        function mapsKnownBoardDisplayNameToPlatformioId(testCase)
            fixture = testCase.applyFixture(matlab.unittest.fixtures.TemporaryFolderFixture);
            iniPath = fullfile(fixture.Folder, "platformio.ini");

            piofrtos.emitPlatformioIni(iniPath, ...
                ModelName="demoModel", ...
                Board="Arduino Nano");

            text = readText(iniPath);
            testCase.verifySubstring(text, "[env:nanoatmega328]");
            testCase.verifySubstring(text, "board = nanoatmega328");
            testCase.verifySubstring(text, "platform = atmelavr");
            testCase.verifySubstring(text, "framework = arduino");
        end
    end
end

function text = readText(filePath)
    text = string(fileread(filePath));
end
