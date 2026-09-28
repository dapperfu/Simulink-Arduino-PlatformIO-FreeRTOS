classdef tPinPull < matlab.unittest.TestCase
    %TPINPULL - Unit tests for enumerated None / Pull-up / Pull-down input options.
    %   Covers pinPullNames, pinPullIndex, validatePinPull, and Level-2 MATLAB digital
    %   input with pull-up parameters. Fixtures add matlab and sfcn paths. Failure means
    %   enum mapping or Uno pull-down rejection drifted.
    %
    %   Syntax:
    %       result = runtests("tPinPull")
    %
    %   Inputs:
    %       none
    %
    %   Outputs:
    %       none. Test methods pass, fail, or throw matlab.unittest results.
    %
    %   Example:
    %       result = runtests("tPinPull");
    %
    %   Other m-files required: arduinopio.pinPullNames, arduinopio.pinPullIndex,
    %       arduinopio.validatePinPull, arduinopio_digital_input
    %   Subfunctions: simulateDigitalInput
    %   MAT-files required: none
    %
    %   See also: TCOMMONIOSFUNCTIONS, ARDUINOPIO.PINPULLINDEX

    %   Author: Frey, Jed
    %   28-Sep-2026; Last revision: 28-Sep-2026

    methods (TestClassSetup)
        function addRepoToPath(testCase)
        %ADDREPOTOPATH - Adds repo, matlab, and sfcn paths for the class.
        %   Applies PathFixture so pin-pull helpers and the digital input S-function
        %   resolve during unit and simulation tests.
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
        %       runtests("tPinPull", "ProcedureName", "addRepoToPath");
        %
        %   See also: TPINPULL
            testsFolder = fileparts(mfilename("fullpath"));
            repoRoot = fileparts(testsFolder);
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture(repoRoot));
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture(fullfile(repoRoot, "matlab")));
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture(fullfile(repoRoot, "sfcn")));
        end
    end

    methods (Test)
        function namesAreEnumerated(testCase)
        %NAMESAREENUMERATED - pinPullNames returns None, Pull-up, and Pull-down.
        %   Asserts the display-name enumeration used by masks and validation helpers.
        %
        %   Syntax:
        %       namesAreEnumerated(testCase)
        %
        %   Inputs:
        %       testCase - matlab.unittest.TestCase instance supplied by the runner.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       runtests("tPinPull", "ProcedureName", "namesAreEnumerated");
        %
        %   See also: TPINPULL, ARDUINOPIO.PINPULLNAMES
            testCase.verifyEqual(arduinopio.pinPullNames(), ["None", "Pull-up", "Pull-down"]);
        end

        function indexMapsDisplayNames(testCase)
        %INDEXMAPSDISPLAYNAMES - pinPullIndex maps display names to 0, 1, and 2.
        %   Verifies None->0, Pull-up->1, and Pull-down->2.
        %
        %   Syntax:
        %       indexMapsDisplayNames(testCase)
        %
        %   Inputs:
        %       testCase - matlab.unittest.TestCase instance supplied by the runner.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       runtests("tPinPull", "ProcedureName", "indexMapsDisplayNames");
        %
        %   See also: TPINPULL, ARDUINOPIO.PINPULLINDEX
            testCase.verifyEqual(arduinopio.pinPullIndex("None"), 0);
            testCase.verifyEqual(arduinopio.pinPullIndex("Pull-up"), 1);
            testCase.verifyEqual(arduinopio.pinPullIndex("Pull-down"), 2);
        end

        function indexMapsNumericValues(testCase)
        %INDEXMAPSNUMERICVALUES - pinPullIndex passes through numeric 0, 1, and 2.
        %   Verifies numeric inputs are returned unchanged as pull indices.
        %
        %   Syntax:
        %       indexMapsNumericValues(testCase)
        %
        %   Inputs:
        %       testCase - matlab.unittest.TestCase instance supplied by the runner.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       runtests("tPinPull", "ProcedureName", "indexMapsNumericValues");
        %
        %   See also: TPINPULL, ARDUINOPIO.PINPULLINDEX
            testCase.verifyEqual(arduinopio.pinPullIndex(0), 0);
            testCase.verifyEqual(arduinopio.pinPullIndex(1), 1);
            testCase.verifyEqual(arduinopio.pinPullIndex(2), 2);
        end

        function invalidNameErrors(testCase)
        %INVALIDNAMEERRORS - Unknown pull names error with arduinopio:InvalidPinPull.
        %   Calls pinPullIndex("Enable pull-up") and expects identifier
        %   arduinopio:InvalidPinPull.
        %
        %   Syntax:
        %       invalidNameErrors(testCase)
        %
        %   Inputs:
        %       testCase - matlab.unittest.TestCase instance supplied by the runner.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       runtests("tPinPull", "ProcedureName", "invalidNameErrors");
        %
        %   See also: TPINPULL, ARDUINOPIO.PINPULLINDEX
            testCase.verifyError(@() arduinopio.pinPullIndex("Enable pull-up"), "arduinopio:InvalidPinPull");
        end

        function pulldownRejectedOnUno(testCase)
        %PULLDOWNREJECTEDONUNO - validatePinPull rejects Pull-down on Uno defaults.
        %   Expects error identifier arduinopio:InvalidPinPull for "Pull-down".
        %
        %   Syntax:
        %       pulldownRejectedOnUno(testCase)
        %
        %   Inputs:
        %       testCase - matlab.unittest.TestCase instance supplied by the runner.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       runtests("tPinPull", "ProcedureName", "pulldownRejectedOnUno");
        %
        %   See also: TPINPULL, ARDUINOPIO.VALIDATEPINPULL
            testCase.verifyError(@() arduinopio.validatePinPull("Pull-down"), "arduinopio:InvalidPinPull");
        end

        function noneAndPullupAcceptedOnUno(testCase)
        %NONEANDPULLUPACCEPTEDONUNO - validatePinPull accepts None and Pull-up.
        %   Asserts both calls are warning-free under default Uno validation.
        %
        %   Syntax:
        %       noneAndPullupAcceptedOnUno(testCase)
        %
        %   Inputs:
        %       testCase - matlab.unittest.TestCase instance supplied by the runner.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       runtests("tPinPull", "ProcedureName", "noneAndPullupAcceptedOnUno");
        %
        %   See also: TPINPULL, ARDUINOPIO.VALIDATEPINPULL
            testCase.verifyWarningFree(@() arduinopio.validatePinPull("None"));
            testCase.verifyWarningFree(@() arduinopio.validatePinPull("Pull-up"));
        end

        function digitalInputAcceptsPullupParameter(testCase)
        %DIGITALINPUTACCEPTSPULLUPPARAMETER - Digital input S-fcn accepts pull-up index 1.
        %   Simulates arduinopio_digital_input with parameters "2, 1, 0.01, 1" (pin,
        %   pull-up, sample time, SimValue) and verifies the last logged output is true.
        %
        %   Syntax:
        %       digitalInputAcceptsPullupParameter(testCase)
        %
        %   Inputs:
        %       testCase - matlab.unittest.TestCase instance supplied by the runner.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       runtests("tPinPull", ...
        %           "ProcedureName", "digitalInputAcceptsPullupParameter");
        %
        %   See also: TPINPULL, SIMULATEDIGITALINPUT
            output = simulateDigitalInput(testCase, "2, 1, 0.01, 1");
            testCase.verifyTrue(logical(output));
        end
    end
end

function output = simulateDigitalInput(testCase, parameters)
%SIMULATEDIGITALINPUT - Host-simulates arduinopio_digital_input and returns last sample.
%   Builds a short fixed-step model with Level-2 MATLAB S-Function parameters, logs the
%   output to the workspace, and returns the final logged row.
%
%   Syntax:
%       output = simulateDigitalInput(testCase, parameters)
%
%   Inputs:
%       testCase - matlab.unittest.TestCase instance for assertTrue on load.
%       parameters - char or string S-Function Parameters vector string.
%
%   Outputs:
%       output - last logged digital input sample from simulation.
%
%   Example:
%       output = simulateDigitalInput(testCase, "2, 1, 0.01, 1");
%
%   See also: TPINPULL
    modelName = "pinPull" + string(randi(1e6));
    new_system(modelName);
    load_system(modelName);
    closer = onCleanup(@() close_system(modelName, 0));
    testCase.assertTrue(bdIsLoaded(modelName));

    set_param(modelName, "StopTime", "0.02", "SolverType", "Fixed-step", "FixedStep", "0.01");
    add_block("simulink/User-Defined Functions/Level-2 MATLAB S-Function", ...
        modelName + "/DUT", Position=[80, 40, 220, 80]);
    set_param(modelName + "/DUT", "FunctionName", "arduinopio_digital_input", "Parameters", parameters);
    add_block("simulink/Sinks/To Workspace", modelName + "/Log", Position=[280, 45, 380, 75]);
    set_param(modelName + "/Log", "VariableName", "logged", "SaveFormat", "Array");
    add_line(modelName, "DUT/1", "Log/1");

    simOut = sim(modelName);
    output = simOut.logged(end, :).';
end
