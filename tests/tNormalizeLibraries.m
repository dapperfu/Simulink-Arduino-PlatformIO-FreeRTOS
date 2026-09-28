classdef tNormalizeLibraries < matlab.unittest.TestCase
    %TNORMALIZELIBRARIES - Locks splitting of extra PlatformIO library entries.
    %   Covers piofrtos.normalizeLibraries for comma/semicolon lists and blank input.
    %   PathFixture adds the repo root. Failure means lib_deps parsing no longer splits
    %   or trims entries correctly.
    %
    %   Syntax:
    %       result = runtests("tNormalizeLibraries")
    %
    %   Inputs:
    %       none
    %
    %   Outputs:
    %       none. Test methods pass, fail, or throw matlab.unittest results.
    %
    %   Example:
    %       result = runtests("tNormalizeLibraries");
    %
    %   Other m-files required: piofrtos.normalizeLibraries
    %   Subfunctions: none
    %   MAT-files required: none
    %
    %   See also: TEMITPLATFORMIOINI, PIOFRTOS.NORMALIZELIBRARIES

    %   Author: Frey, Jed
    %   28-Sep-2026; Last revision: 28-Sep-2026

    methods (TestClassSetup)
        function addRepoToPath(testCase)
        %ADDREPOTOPATH - Adds the repository root to the MATLAB path for the class.
        %   Resolves the repo root from this test file location and applies PathFixture so
        %   piofrtos.normalizeLibraries resolves during the suite.
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
        %       runtests("tNormalizeLibraries", "ProcedureName", "addRepoToPath");
        %
        %   See also: TNORMALIZELIBRARIES
            testsFolder = fileparts(mfilename("fullpath"));
            repoRoot = fileparts(testsFolder);
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture(repoRoot));
        end
    end

    methods (Test)
        function splitsCommaAndSemicolonLists(testCase)
        %SPLITSCOMMAANDSEMICOLONLISTS - Splits mixed comma and semicolon library lists.
        %   Parses FreeRTOS, ArduinoJson, and PubSubClient separated by comma and
        %   semicolon and verifies a column string array of the three trimmed names.
        %
        %   Syntax:
        %       splitsCommaAndSemicolonLists(testCase)
        %
        %   Inputs:
        %       testCase - matlab.unittest.TestCase instance supplied by the runner.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       runtests("tNormalizeLibraries", ...
        %           "ProcedureName", "splitsCommaAndSemicolonLists");
        %
        %   See also: TNORMALIZELIBRARIES, PIOFRTOS.NORMALIZELIBRARIES
            libraries = piofrtos.normalizeLibraries("feilipu/FreeRTOS, bblanchon/ArduinoJson; knolleary/PubSubClient");
            testCase.verifyEqual(libraries(:), [ ...
                "feilipu/FreeRTOS"; ...
                "bblanchon/ArduinoJson"; ...
                "knolleary/PubSubClient"]);
        end

        function emptyStringReturnsEmpty(testCase)
        %EMPTYSTRINGRETURNSEMPTY - Whitespace-only input yields an empty library list.
        %   Calls normalizeLibraries("   ") and verifies the result is empty.
        %
        %   Syntax:
        %       emptyStringReturnsEmpty(testCase)
        %
        %   Inputs:
        %       testCase - matlab.unittest.TestCase instance supplied by the runner.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       runtests("tNormalizeLibraries", ...
        %           "ProcedureName", "emptyStringReturnsEmpty");
        %
        %   See also: TNORMALIZELIBRARIES, PIOFRTOS.NORMALIZELIBRARIES
            libraries = piofrtos.normalizeLibraries("   ");
            testCase.verifyEmpty(libraries);
        end
    end
end
