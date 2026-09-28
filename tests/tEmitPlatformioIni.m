classdef tEmitPlatformioIni < matlab.unittest.TestCase
    %TEMITPLATFORMIOINI - Locks platformio.ini generation for Arduino FreeRTOS builds.
    %   Covers piofrtos.emitPlatformioIni writing env sections, libraries, defines, and
    %   known board display-name mapping. PathFixture adds the repo root. Local readText
    %   loads file content. Failure means wrong env id, missing deps, or unwanted lib_deps.
    %
    %   Syntax:
    %       result = runtests("tEmitPlatformioIni")
    %
    %   Inputs:
    %       none
    %
    %   Outputs:
    %       none. Test methods pass, fail, or throw matlab.unittest results.
    %
    %   Example:
    %       result = runtests("tEmitPlatformioIni");
    %
    %   Other m-files required: piofrtos.emitPlatformioIni
    %   Subfunctions: readText
    %   MAT-files required: none
    %
    %   See also: TKNOWNTARGETS, PIOFRTOS.EMITPLATFORMIOINI

    %   Author: Frey, Jed
    %   28-Sep-2026; Last revision: 28-Sep-2026

    methods (TestClassSetup)
        function addRepoToPath(testCase)
        %ADDREPOTOPATH - Adds the repository root to the MATLAB path for the class.
        %   Resolves the repo root from this test file location and applies PathFixture so
        %   piofrtos.emitPlatformioIni resolves during the suite.
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
        %       runtests("tEmitPlatformioIni", "ProcedureName", "addRepoToPath");
        %
        %   See also: TEMITPLATFORMIOINI
            testsFolder = fileparts(mfilename("fullpath"));
            repoRoot = fileparts(testsFolder);
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture(repoRoot));
        end
    end

    methods (Test)
        function writesBoardPlatformAndLibraries(testCase)
        %WRITESBOARDPLATFORMANDLIBRARIES - Writes env, platform, board, and lib_deps.
        %   Emits ini for demoModel with atmelavr/uno/arduino, FreeRTOS and ArduinoJson
        %   extras, monitor 9600, include flags, and defines. Asserts env:uno, libraries,
        %   -DMODEL=demoModel, -<ert_main.c>, and src_dir = .
        %
        %   Syntax:
        %       writesBoardPlatformAndLibraries(testCase)
        %
        %   Inputs:
        %       testCase - matlab.unittest.TestCase instance supplied by the runner.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       runtests("tEmitPlatformioIni", ...
        %           "ProcedureName", "writesBoardPlatformAndLibraries");
        %
        %   See also: TEMITPLATFORMIOINI, PIOFRTOS.EMITPLATFORMIOINI
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
        %OMITSLIBDEPSWHENEMPTY - Omits lib_deps when ExtraLibraries is not supplied.
        %   Emits ini with only ModelName and asserts no lib_deps line while still writing
        %   default [env:uno], atmelavr platform, and uno board.
        %
        %   Syntax:
        %       omitsLibDepsWhenEmpty(testCase)
        %
        %   Inputs:
        %       testCase - matlab.unittest.TestCase instance supplied by the runner.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       runtests("tEmitPlatformioIni", "ProcedureName", "omitsLibDepsWhenEmpty");
        %
        %   See also: TEMITPLATFORMIOINI, PIOFRTOS.EMITPLATFORMIOINI
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
        %MAPSKNOWNBOARDDISPLAYNAMETOPLATFORMIOID - Maps Arduino Nano to nanoatmega328.
        %   Emits ini with Board="Arduino Nano" and asserts env/board nanoatmega328 with
        %   atmelavr platform and arduino framework from the known-target table.
        %
        %   Syntax:
        %       mapsKnownBoardDisplayNameToPlatformioId(testCase)
        %
        %   Inputs:
        %       testCase - matlab.unittest.TestCase instance supplied by the runner.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       runtests("tEmitPlatformioIni", ...
        %           "ProcedureName", "mapsKnownBoardDisplayNameToPlatformioId");
        %
        %   See also: TEMITPLATFORMIOINI, PIOFRTOS.RESOLVEKNOWNTARGET
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
%READTEXT - Reads a text file into a string scalar for substring assertions.
%   Wraps fileread and string conversion used by emitPlatformioIni tests.
%
%   Syntax:
%       text = readText(filePath)
%
%   Inputs:
%       filePath - char or string path to the platformio.ini under test.
%
%   Outputs:
%       text - string scalar containing the file contents.
%
%   Example:
%       text = readText(fullfile(tempdir, "platformio.ini"));
%
%   See also: TEMITPLATFORMIOINI
    text = string(fileread(filePath));
end
