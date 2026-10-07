classdef tBoardDrivers < matlab.unittest.TestCase
    %TBOARDDRIVERS - Board maps and System objects that replaced the stubs.
    %   Checks pin validation, library dependencies, and that each former stub
    %   board is marked implemented. Fixtures add the repo and matlab paths.
    %
    %   Syntax:
    %       result = runtests("tBoardDrivers")
    %
    %   Inputs:
    %       none
    %
    %   Outputs:
    %       none
    %
    %   Example:
    %       result = runtests("tBoardDrivers");
    %
    %   Other m-files required: arduinopio.validateBoardPin, arduinopio.knownLibDeps
    %   Subfunctions: none
    %   MAT-files required: none
    %
    %   See also: TKNOWNTARGETS, VALIDATEBOARDPIN

    %   Author: Frey, Jed
    %   07-Oct-2026; Last revision: 07-Oct-2026

    methods (TestClassSetup)
        function addRepoToPath(testCase)
            testsFolder = fileparts(mfilename("fullpath"));
            repoRoot = fileparts(testsFolder);
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture(repoRoot));
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture(fullfile(repoRoot, "matlab")));
        end
    end

    methods (Test)
        function formerStubsAreImplemented(testCase)
            names = ["mega2560", "due", "mkrWifi1010", "esp32Wroom", "unoR4", "nano33Ble"];
            for nameIndex = 1:numel(names)
                info = arduinopio.boards.getBoard(names(nameIndex));
                testCase.verifyEqual(info.Name, names(nameIndex));
                testCase.verifyTrue(info.Implemented, names(nameIndex));
            end
            nanoBle = arduinopio.boards.getBoard("nano33Ble");
            testCase.verifyFalse(nanoBle.HasDac);
            dueInfo = arduinopio.boards.getBoard("due");
            testCase.verifyEqual(dueInfo.DacPins, [66, 67]);
            testCase.verifyEqual(dueInfo.CanControllerCount, 2);
        end

        function validatesBoardSpecificPins(testCase)
            arduinopio.validateBoardPin("mega2560", 54, "digital");
            arduinopio.validateBoardPin("mega2560", 15, "analog");
            arduinopio.validateBoardPin("due", 66, "dac");
            arduinopio.validateBoardPin("esp32Wroom", 4, "touch");
            arduinopio.validateBoardPin("mega2560", 1, "uart");
            testCase.verifyError(@() arduinopio.validateBoardPin("uno", 66, "dac"), ...
                "arduinopio:InvalidPin");
            testCase.verifyError(@() arduinopio.validateBoardPin("nano33Ble", 15, "dac"), ...
                "arduinopio:InvalidPin");
        end

        function dacWriteRejectsNonDacPin(testCase)
            block = arduinopio.blocks.common.DacWrite(Board="due", Pin=3);
            testCase.verifyError(@() setup(block), "arduinopio:InvalidPin");
        end

        function knownLibrariesIncludeBoardDependencies(testCase)
            deps = arduinopio.knownLibDeps();
            defines = string({deps.Define});
            testCase.verifyTrue(any(defines == "ARDUINOPIO_NEED_WIFININA"));
            testCase.verifyTrue(any(defines == "ARDUINOPIO_NEED_WIFIS3"));
            testCase.verifyTrue(any(defines == "ARDUINOPIO_NEED_ARDUINOBLE"));
            testCase.verifyTrue(any(defines == "ARDUINOPIO_NEED_ARDUINO_CAN"));
            testCase.verifyTrue(any(defines == "ARDUINOPIO_NEED_LED_MATRIX"));
        end
    end
end
