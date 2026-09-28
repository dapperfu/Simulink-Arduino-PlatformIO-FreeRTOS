classdef tPinMaskDisplay < matlab.unittest.TestCase
    % Pin-taking blocks must show the pin number on the mask or System icon.

    methods (TestClassSetup)
        function addRepoToPath(testCase)
            testsFolder = fileparts(mfilename("fullpath"));
            repoRoot = fileparts(testsFolder);
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture(repoRoot));
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture(fullfile(repoRoot, "matlab")));
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture(fullfile(repoRoot, "sfcn")));
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture(fullfile(repoRoot, "libraries")));
            setupArduinoPioPath();
        end
    end

    methods (Test)
        function helperFormatsSingleAndMultiplePins(testCase)
            testCase.verifyEqual(arduinopio.iconWithPin("PWM", 5), ["PWM"; "Pin 5"]);
            testCase.verifyEqual(arduinopio.iconWithPin("Encoder", [2, 3]), ["Encoder"; "Pins 2, 3"]);
            testCase.verifyEqual(arduinopio.iconWithPin("SPI", 10, Label="CS"), ["SPI"; "CS 10"]);
        end

        function helperFormatsMaskDisplayCommand(testCase)
            command = arduinopio.maskDisplayWithPin("Digital Output");
            testCase.verifyEqual(command, "fprintf('Digital Output\\nPin %g', Pin)");
        end

        function pinSystemObjectsCallIconWithPin(testCase)
            blocksFolder = fullfile(arduinopio.getRootFolder(), "matlab", "+arduinopio", "+blocks");
            fileList = dir(fullfile(blocksFolder, "**", "*.m"));
            missing = strings(0, 1);
            for fileIndex = 1:numel(fileList)
                filePath = fullfile(fileList(fileIndex).folder, fileList(fileIndex).name);
                text = string(fileread(filePath));
                if ~hasPinProperty(text)
                    continue
                end
                if ~contains(text, "arduinopio.iconWithPin")
                    missing(end+1, 1) = string(fileList(fileIndex).name); %#ok<AGROW>
                end
            end
            testCase.verifyEmpty(missing, "Missing iconWithPin in: " + strjoin(missing, ", "));
        end

        function libraryMasksShowPin(testCase)
            createArduinoPioLibrary();
            if bdIsLoaded("arduinopio_lib")
                close_system("arduinopio_lib", 0);
            end
            load_system(fullfile(arduinopio.getRootFolder(), "libraries", "arduinopio_lib.slx"));
            closer = onCleanup(@() close_system("arduinopio_lib", 0));

            blockPaths = arduinopio.listLibraryBlocks();
            pinMasks = strings(0, 1);
            missingDisplay = strings(0, 1);
            for blockIndex = 1:numel(blockPaths)
                blockPath = blockPaths(blockIndex);
                maskNames = string(get_param(blockPath, "MaskNames"));
                if ~any(maskNames == "Pin") && ~any(maskNames == "ChipSelectPin") ...
                        && ~any(maskNames == "PinA")
                    continue
                end
                pinMasks(end+1, 1) = blockPath; %#ok<AGROW>
                displayText = string(get_param(blockPath, "MaskDisplay"));
                if ~contains(displayText, "Pin") && ~contains(displayText, "CS")
                    missingDisplay(end+1, 1) = blockPath + " display='" + displayText + "'"; %#ok<AGROW>
                end
            end

            testCase.verifyGreaterThanOrEqual(numel(pinMasks), 5);
            testCase.verifyEmpty(missingDisplay, strjoin(missingDisplay, newline));
        end
    end
end

function tf = hasPinProperty(text)
    tf = contains(text, "Pin (1,1)") || contains(text, "PinA (1,1)") ...
        || contains(text, "ChipSelectPin (1,1)");
end
