classdef tLibraryBlockCodegen < matlab.unittest.TestCase
    % Put every Arduino PIO library block in a fixed-step model and generate code.

    properties
        WorkFolder
        PreviousFileGen
        LibraryCloser
    end

    methods (TestClassSetup)
        function addRepoToPath(testCase)
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
            if ~isempty(testCase.PreviousFileGen)
                Simulink.fileGenControl("setConfig", config=testCase.PreviousFileGen);
            end
        end
    end

    methods (Test)
        function everyLibraryBlockGeneratesCode(testCase)
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
