classdef tGetDefaultOptions < matlab.unittest.TestCase
    % Tests for PlatformIO target option defaults.

    methods (TestClassSetup)
        function addRepoToPath(testCase)
            testsFolder = fileparts(mfilename("fullpath"));
            repoRoot = fileparts(testsFolder);
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture(repoRoot));
        end
    end

    methods (Test)
        function defaultBoardIsArduinoUno(testCase)
            options = piofrtos.getDefaultOptions();
            testCase.verifyEqual(options.PioBoard, "Arduino Uno");
            testCase.verifyEqual(options.PioPlatform, "atmelavr");
            testCase.verifyEqual(options.PioFramework, "arduino");
            testCase.verifyEqual(options.PioExtraLibraries, "feilipu/FreeRTOS");
            testCase.verifyEqual(options.PioTaskStackWords, "192");
        end

        function platformBoardAndFrameworkArePopups(testCase)
            optionTable = piofrtos.getOptionTable();
            names = string({optionTable.Name});
            platformOption = optionTable(names == "PioPlatform");
            boardOption = optionTable(names == "PioBoard");
            frameworkOption = optionTable(names == "PioFramework");

            testCase.verifyEqual(platformOption.Type, "Popup");
            testCase.verifyEqual(boardOption.Type, "Popup");
            testCase.verifyEqual(frameworkOption.Type, "Popup");
            testCase.verifyEqual(platformOption.PopupStrings, "atmelavr");
            testCase.verifyEqual(boardOption.PopupStrings, "Arduino Uno|Arduino Nano");
            testCase.verifyEqual(frameworkOption.PopupStrings, "arduino");
            testCase.verifyEqual(boardOption.Callback, "piofrtos.syncKnownTarget(hDlg, hSrc)");
        end

        function optionTableMatchesDefaults(testCase)
            options = piofrtos.getDefaultOptions();
            optionTable = piofrtos.getOptionTable();
            for optionIndex = 1:numel(optionTable)
                name = optionTable(optionIndex).Name;
                testCase.verifyTrue(isfield(options, name), ...
                    "Missing default for " + name);
                testCase.verifyEqual(options.(name), optionTable(optionIndex).Default);
            end
        end
    end
end
