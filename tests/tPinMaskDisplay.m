classdef tPinMaskDisplay < matlab.unittest.TestCase
    %TPINMASKDISPLAY - Pin-taking blocks must show the pin on the mask or System icon.
    %   Covers arduinopio.iconWithPin, maskDisplayWithPin, System object sources under
    %   +blocks, and library MaskDisplay text. Fixtures add repo, matlab, sfcn, and
    %   libraries paths and call setupArduinoPioPath. Failure means icons or masks omit
    %   pin labeling for pin-configured blocks.
    %
    %   Syntax:
    %       result = runtests("tPinMaskDisplay")
    %
    %   Inputs:
    %       none
    %
    %   Outputs:
    %       none. Test methods pass, fail, or throw matlab.unittest results.
    %
    %   Example:
    %       result = runtests("tPinMaskDisplay");
    %
    %   Other m-files required: arduinopio.iconWithPin, arduinopio.maskDisplayWithPin,
    %       setupArduinoPioPath, createArduinoPioLibrary, arduinopio.listLibraryBlocks
    %   Subfunctions: hasPinProperty
    %   MAT-files required: none
    %
    %   See also: TLIBRARYBLOCKCODEGEN, ARDUINOPIO.ICONWITHPIN

    %   Author: Frey, Jed
    %   28-Sep-2026; Last revision: 28-Sep-2026

    methods (TestClassSetup)
        function addRepoToPath(testCase)
        %ADDREPOTOPATH - Adds repo paths and runs setupArduinoPioPath for the class.
        %   Applies PathFixture for the repo root, matlab, sfcn, and libraries folders,
        %   then calls setupArduinoPioPath so library and block helpers resolve.
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
        %       runtests("tPinMaskDisplay", "ProcedureName", "addRepoToPath");
        %
        %   See also: TPINMASKDISPLAY
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
        %HELPERFORMATSSINGLEANDMULTIPLEPINS - Formats icon lines for one or many pins.
        %   Asserts iconWithPin returns two-line string arrays for PWM pin 5, Encoder pins
        %   2 and 3, and SPI with Label="CS" for chip-select pin 10.
        %
        %   Syntax:
        %       helperFormatsSingleAndMultiplePins(testCase)
        %
        %   Inputs:
        %       testCase - matlab.unittest.TestCase instance supplied by the runner.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       runtests("tPinMaskDisplay", ...
        %           "ProcedureName", "helperFormatsSingleAndMultiplePins");
        %
        %   See also: TPINMASKDISPLAY, ARDUINOPIO.ICONWITHPIN
            testCase.verifyEqual(arduinopio.iconWithPin("PWM", 5), ["PWM"; "Pin 5"]);
            testCase.verifyEqual(arduinopio.iconWithPin("Encoder", [2, 3]), ["Encoder"; "Pins 2, 3"]);
            testCase.verifyEqual(arduinopio.iconWithPin("SPI", 10, Label="CS"), ["SPI"; "CS 10"]);
        end

        function helperFormatsMaskDisplayCommand(testCase)
        %HELPERFORMATSMASKDISPLAYCOMMAND - Builds the MaskDisplay fprintf command string.
        %   Calls maskDisplayWithPin("Digital Output") and expects the Pin %g fprintf
        %   command used on library block masks.
        %
        %   Syntax:
        %       helperFormatsMaskDisplayCommand(testCase)
        %
        %   Inputs:
        %       testCase - matlab.unittest.TestCase instance supplied by the runner.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       runtests("tPinMaskDisplay", ...
        %           "ProcedureName", "helperFormatsMaskDisplayCommand");
        %
        %   See also: TPINMASKDISPLAY, ARDUINOPIO.MASKDISPLAYWITHPIN
            command = arduinopio.maskDisplayWithPin("Digital Output");
            testCase.verifyEqual(command, "fprintf('Digital Output\\nPin %g', Pin)");
        end

        function pinSystemObjectsCallIconWithPin(testCase)
        %PINSYSTEMOBJECTSCALLICONWITHPIN - Pin System objects must call iconWithPin.
        %   Scans +arduinopio/+blocks *.m files that declare Pin, PinA, or ChipSelectPin
        %   properties and fails if any omit arduinopio.iconWithPin in the source text.
        %
        %   Syntax:
        %       pinSystemObjectsCallIconWithPin(testCase)
        %
        %   Inputs:
        %       testCase - matlab.unittest.TestCase instance supplied by the runner.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       runtests("tPinMaskDisplay", ...
        %           "ProcedureName", "pinSystemObjectsCallIconWithPin");
        %
        %   See also: TPINMASKDISPLAY, HASPINPROPERTY
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
        %LIBRARYMASKSSHOWPIN - Library pin masks include Pin or CS in MaskDisplay.
        %   Rebuilds and loads arduinopio_lib, finds blocks with Pin, ChipSelectPin, or
        %   PinA mask parameters, requires at least five such blocks, and asserts each
        %   MaskDisplay contains "Pin" or "CS".
        %
        %   Syntax:
        %       libraryMasksShowPin(testCase)
        %
        %   Inputs:
        %       testCase - matlab.unittest.TestCase instance supplied by the runner.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       runtests("tPinMaskDisplay", "ProcedureName", "libraryMasksShowPin");
        %
        %   See also: TPINMASKDISPLAY, CREATEARDUINOPIOLIBRARY
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
%HASPINPROPERTY - True when source text declares a pin-related property.
%   Returns logical true if text contains Pin (1,1), PinA (1,1), or ChipSelectPin (1,1)
%   property declarations used by System object block sources.
%
%   Syntax:
%       tf = hasPinProperty(text)
%
%   Inputs:
%       text - string scalar of System object M-file contents.
%
%   Outputs:
%       tf - logical scalar, true when a pin property declaration is present.
%
%   Example:
%       tf = hasPinProperty(string(fileread("DigitalInput.m")));
%
%   See also: TPINMASKDISPLAY
    tf = contains(text, "Pin (1,1)") || contains(text, "PinA (1,1)") ...
        || contains(text, "ChipSelectPin (1,1)");
end
