classdef tGetDefaultOptions < matlab.unittest.TestCase
    %TGETDEFAULTOPTIONS - Locks PlatformIO target option defaults and popup metadata.
    %   Covers piofrtos.getDefaultOptions and getOptionTable for PioBoard, platform,
    %   framework, libraries, and stack words. PathFixture adds the repo root. Failure
    %   means defaults or popup strings drifted from the supported Uno/Nano set.
    %
    %   Syntax:
    %       result = runtests("tGetDefaultOptions")
    %
    %   Inputs:
    %       none
    %
    %   Outputs:
    %       none. Test methods pass, fail, or throw matlab.unittest results.
    %
    %   Example:
    %       result = runtests("tGetDefaultOptions");
    %
    %   Other m-files required: piofrtos.getDefaultOptions, piofrtos.getOptionTable
    %   Subfunctions: none
    %   MAT-files required: none
    %
    %   See also: TGENERATETARGETFILES, PIOFRTOS.GETDEFAULTOPTIONS

    %   Author: Frey, Jed
    %   28-Sep-2026; Last revision: 28-Sep-2026

    methods (TestClassSetup)
        function addRepoToPath(testCase)
        %ADDREPOTOPATH - Adds the repository root to the MATLAB path for the class.
        %   Resolves the repo root from this test file location and applies PathFixture so
        %   piofrtos option helpers resolve during the suite.
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
        %       runtests("tGetDefaultOptions", "ProcedureName", "addRepoToPath");
        %
        %   See also: TGETDEFAULTOPTIONS
            testsFolder = fileparts(mfilename("fullpath"));
            repoRoot = fileparts(testsFolder);
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture(repoRoot));
        end
    end

    methods (Test)
        function defaultBoardIsArduinoUno(testCase)
        %DEFAULTBOARDISARDUINOUNO - Default options select Uno AVR Arduino FreeRTOS.
        %   Calls getDefaultOptions and verifies PioBoard Arduino Uno, PioPlatform
        %   atmelavr, PioFramework arduino, PioExtraLibraries feilipu/FreeRTOS, and
        %   PioTaskStackWords 192.
        %
        %   Syntax:
        %       defaultBoardIsArduinoUno(testCase)
        %
        %   Inputs:
        %       testCase - matlab.unittest.TestCase instance supplied by the runner.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       runtests("tGetDefaultOptions", ...
        %           "ProcedureName", "defaultBoardIsArduinoUno");
        %
        %   See also: TGETDEFAULTOPTIONS, PIOFRTOS.GETDEFAULTOPTIONS
            options = piofrtos.getDefaultOptions();
            testCase.verifyEqual(options.PioBoard, "Arduino Uno");
            testCase.verifyEqual(options.PioPlatform, "atmelavr");
            testCase.verifyEqual(options.PioFramework, "arduino");
            testCase.verifyEqual(options.PioExtraLibraries, "feilipu/FreeRTOS");
            testCase.verifyEqual(options.PioTaskStackWords, "192");
        end

        function platformBoardAndFrameworkArePopups(testCase)
        %PLATFORMBOARDANDFRAMEWORKAREPOPUPS - Platform, board, and framework are popups.
        %   Reads getOptionTable rows for PioPlatform, PioBoard, and PioFramework and
        %   verifies Type Popup, popup strings, and board Callback syncKnownTarget.
        %
        %   Syntax:
        %       platformBoardAndFrameworkArePopups(testCase)
        %
        %   Inputs:
        %       testCase - matlab.unittest.TestCase instance supplied by the runner.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       runtests("tGetDefaultOptions", ...
        %           "ProcedureName", "platformBoardAndFrameworkArePopups");
        %
        %   See also: TGETDEFAULTOPTIONS, PIOFRTOS.GETOPTIONTABLE
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
        %OPTIONTABLEMATCHESDEFAULTS - Every option table Default matches getDefaultOptions.
        %   Iterates getOptionTable entries and verifies each Name is a field on
        %   getDefaultOptions with equal Default value.
        %
        %   Syntax:
        %       optionTableMatchesDefaults(testCase)
        %
        %   Inputs:
        %       testCase - matlab.unittest.TestCase instance supplied by the runner.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       runtests("tGetDefaultOptions", ...
        %           "ProcedureName", "optionTableMatchesDefaults");
        %
        %   See also: TGETDEFAULTOPTIONS, PIOFRTOS.GETOPTIONTABLE
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
