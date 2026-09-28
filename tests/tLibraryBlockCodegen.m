classdef tLibraryBlockCodegen < matlab.unittest.TestCase
    %TLIBRARYBLOCKCODEGEN - Every Arduino PIO library block must generate code.
    %   Places each library block in a fixed-step model via generateLibraryBlockCode.
    %   TestClassSetup builds S-functions if needed, creates the library, loads it, and
    %   redirects Simulink fileGen folders. TestClassTeardown restores fileGen. Failure
    %   means one or more blocks threw during code generation.
    %
    %   Syntax:
    %       result = runtests("tLibraryBlockCodegen")
    %
    %   Inputs:
    %       none
    %
    %   Outputs:
    %       none. Test methods pass, fail, or throw matlab.unittest results.
    %
    %   Example:
    %       result = runtests("tLibraryBlockCodegen");
    %
    %   Other m-files required: setup_piofrtos, buildArduinoPioSFunctions,
    %       createArduinoPioLibrary, arduinopio.listLibraryBlocks,
    %       arduinopio.generateLibraryBlockCode
    %   Subfunctions: none
    %   MAT-files required: none
    %
    %   See also: TPINMASKDISPLAY, ARDUINOPIO.GENERATELIBRARYBLOCKCODE

    %   Author: Frey, Jed
    %   28-Sep-2026; Last revision: 28-Sep-2026

    properties
        WorkFolder
        PreviousFileGen
        LibraryCloser
    end

    methods (TestClassSetup)
        function addRepoToPath(testCase)
        %ADDREPOTOPATH - Prepares paths, library, S-functions, and fileGen folders.
        %   Adds repo, matlab, sfcn, piofrtos, libraries, and examples to the path, runs
        %   setup_piofrtos, builds mex if needed, creates and loads arduinopio_lib, and
        %   redirects CacheFolder/CodeGenFolder to a temp work folder.
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
        %       runtests("tLibraryBlockCodegen", "ProcedureName", "addRepoToPath");
        %
        %   See also: TLIBRARYBLOCKCODEGEN
            testsFolder = fileparts(mfilename("fullpath"));
            repoRoot = fileparts(testsFolder);
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture(repoRoot));
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture(fullfile(repoRoot, "matlab")));
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture(fullfile(repoRoot, "sfcn")));
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture(fullfile(repoRoot, "piofrtos")));
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture(fullfile(repoRoot, "libraries")));
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture(fullfile(repoRoot, "examples")));

            setup_piofrtos();
            if exist("arduinopio_digital_input_c", "file") ~= 3
                buildArduinoPioSFunctions();
            end
            createArduinoPioLibrary();

            if bdIsLoaded("arduinopio_lib")
                close_system("arduinopio_lib", 0);
            end
            load_system(fullfile(repoRoot, "libraries", "arduinopio_lib.slx"));
            testCase.LibraryCloser = onCleanup(@() close_system("arduinopio_lib", 0));

            testCase.WorkFolder = fullfile(tempdir, "arduinopioLibraryCodegen");
            if ~isfolder(testCase.WorkFolder)
                mkdir(testCase.WorkFolder);
            end
            testCase.PreviousFileGen = Simulink.fileGenControl("getConfig");
            Simulink.fileGenControl("set", ...
                "CacheFolder", testCase.WorkFolder, ...
                "CodeGenFolder", testCase.WorkFolder, ...
                "keepPreviousPath", true);
        end
    end

    methods (TestClassTeardown)
        function restoreFileGen(testCase)
        %RESTOREFILEGEN - Restores Simulink.fileGenControl configuration after tests.
        %   If PreviousFileGen was captured in setup, calls setConfig to reinstate the
        %   prior cache and code-generation folders.
        %
        %   Syntax:
        %       restoreFileGen(testCase)
        %
        %   Inputs:
        %       testCase - matlab.unittest.TestCase instance supplied by the runner.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       runtests("tLibraryBlockCodegen", "ProcedureName", "restoreFileGen");
        %
        %   See also: TLIBRARYBLOCKCODEGEN
            if ~isempty(testCase.PreviousFileGen)
                Simulink.fileGenControl("setConfig", config=testCase.PreviousFileGen);
            end
        end
    end

    methods (Test)
        function everyLibraryBlockGeneratesCode(testCase)
        %EVERYLIBRARYBLOCKGENERATESCODE - Each library block generates without error.
        %   Lists at least twenty library blocks and calls generateLibraryBlockCode for
        %   each into WorkFolder, collecting exception messages. Asserts the failure list
        %   is empty.
        %
        %   Syntax:
        %       everyLibraryBlockGeneratesCode(testCase)
        %
        %   Inputs:
        %       testCase - matlab.unittest.TestCase instance supplied by the runner.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       runtests("tLibraryBlockCodegen", ...
        %           "ProcedureName", "everyLibraryBlockGeneratesCode");
        %
        %   See also: TLIBRARYBLOCKCODEGEN, ARDUINOPIO.GENERATELIBRARYBLOCKCODE
            blockPaths = arduinopio.listLibraryBlocks();
            testCase.assertGreaterThanOrEqual(numel(blockPaths), 20);

            failures = strings(0, 1);
            for blockIndex = 1:numel(blockPaths)
                blockPath = blockPaths(blockIndex);
                try
                    arduinopio.generateLibraryBlockCode(blockPath, testCase.WorkFolder);
                catch exception
                    failures(end+1, 1) = blockPath + ": " + string(exception.message); %#ok<AGROW>
                end
            end

            testCase.verifyEmpty(failures, strjoin(failures, newline));
        end
    end
end
