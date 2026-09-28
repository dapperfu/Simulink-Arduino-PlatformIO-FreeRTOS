classdef tEmitFreeRtosMain < matlab.unittest.TestCase
    %TEMITFREERTOSMAIN - Locks FreeRTOS main.cpp generation from sample rates.
    %   Covers piofrtos.emitFreeRtosMain writing setup/loop and one FreeRTOS task per rate.
    %   PathFixture adds the repo root. Local makeRate builds rate structs. Failure means
    %   wrong step calls, tick periods, priorities, or missing scheduler start.
    %
    %   Syntax:
    %       result = runtests("tEmitFreeRtosMain")
    %
    %   Inputs:
    %       none
    %
    %   Outputs:
    %       none. Test methods pass, fail, or throw matlab.unittest results.
    %
    %   Example:
    %       result = runtests("tEmitFreeRtosMain");
    %
    %   Other m-files required: piofrtos.emitFreeRtosMain
    %   Subfunctions: makeRate
    %   MAT-files required: none
    %
    %   See also: TEMITPLATFORMIOINI, PIOFRTOS.EMITFREERTOSMAIN

    %   Author: Frey, Jed
    %   28-Sep-2026; Last revision: 28-Sep-2026

    methods (TestClassSetup)
        function addRepoToPath(testCase)
        %ADDREPOTOPATH - Adds the repository root to the MATLAB path for the class.
        %   Resolves the repo root from this test file location and applies PathFixture so
        %   piofrtos.emitFreeRtosMain resolves during the suite.
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
        %       runtests("tEmitFreeRtosMain", "ProcedureName", "addRepoToPath");
        %
        %   See also: TEMITFREERTOSMAIN
            testsFolder = fileparts(mfilename("fullpath"));
            repoRoot = fileparts(testsFolder);
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture(repoRoot));
        end
    end

    methods (Test)
        function createsOneTaskPerRate(testCase)
        %CREATESONETASKPERRATE - Emits one xTaskCreate and step call per rate entry.
        %   Builds two rates (10 ms priority 2, 100 ms priority 1) with custom header,
        %   init, stack, and monitor speed. Asserts both steps, pdMS_TO_TICKS values,
        %   vTaskDelayUntil, init include, two xTaskCreate calls, priorities, ESP32
        %   guard, vTaskStartScheduler, and Arduino setup/loop.
        %
        %   Syntax:
        %       createsOneTaskPerRate(testCase)
        %
        %   Inputs:
        %       testCase - matlab.unittest.TestCase instance supplied by the runner.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       runtests("tEmitFreeRtosMain", "ProcedureName", "createsOneTaskPerRate");
        %
        %   See also: TEMITFREERTOSMAIN, MAKERATE
            fixture = testCase.applyFixture(matlab.unittest.fixtures.TemporaryFolderFixture);
            mainPath = fullfile(fixture.Folder, "main.cpp");

            rates = [ ...
                makeRate(0, 0.01, "demo_step0", 2, "rate0"), ...
                makeRate(1, 0.1, "demo_step1", 1, "rate1")];

            piofrtos.emitFreeRtosMain(mainPath, "demo", rates, ...
                HeaderFile="demo.h", ...
                InitFunction="demo_initialize", ...
                StackWords="2048", ...
                MonitorSpeed="115200");

            text = string(fileread(mainPath));
            testCase.verifySubstring(text, "demo_step0();");
            testCase.verifySubstring(text, "demo_step1();");
            testCase.verifySubstring(text, "pdMS_TO_TICKS(10)");
            testCase.verifySubstring(text, "pdMS_TO_TICKS(100)");
            testCase.verifySubstring(text, "vTaskDelayUntil");
            testCase.verifySubstring(text, "demo_initialize();");
            testCase.verifySubstring(text, "#include ""demo.h""");
            testCase.verifyEqual(count(text, "xTaskCreate("), 2);
            testCase.verifySubstring(text, "tskIDLE_PRIORITY + 2");
            testCase.verifySubstring(text, "tskIDLE_PRIORITY + 1");
            testCase.verifySubstring(text, "#if !defined(ARDUINO_ARCH_ESP32)");
            testCase.verifySubstring(text, "vTaskStartScheduler();");
            testCase.verifySubstring(text, "void setup()");
            testCase.verifySubstring(text, "void loop()");
        end

        function singleRateUsesModelStep(testCase)
        %SINGLERATEUSESMODELSTEP - Single-rate main uses model_step and defaults.
        %   Emits main for model "plant" with one 20 ms rate and default options. Asserts
        %   plant.h include comment, plant_initialize, plant_step, and exactly one
        %   xTaskCreate.
        %
        %   Syntax:
        %       singleRateUsesModelStep(testCase)
        %
        %   Inputs:
        %       testCase - matlab.unittest.TestCase instance supplied by the runner.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       runtests("tEmitFreeRtosMain", ...
        %           "ProcedureName", "singleRateUsesModelStep");
        %
        %   See also: TEMITFREERTOSMAIN, MAKERATE
            fixture = testCase.applyFixture(matlab.unittest.fixtures.TemporaryFolderFixture);
            mainPath = fullfile(fixture.Folder, "main.cpp");
            rates = makeRate(0, 0.02, "plant_step", 1, "rate0");

            piofrtos.emitFreeRtosMain(mainPath, "plant", rates);
            text = string(fileread(mainPath));
            testCase.verifySubstring(text, "#include ""plant.h""");
            testCase.verifySubstring(text, "Includes the generated model plant");
            testCase.verifySubstring(text, "plant_initialize();");
            testCase.verifySubstring(text, "plant_step();");
            testCase.verifyEqual(count(text, "xTaskCreate("), 1);
        end
    end
end

function rate = makeRate(index, periodSeconds, stepFunction, priority, taskName)
%MAKERATE - Builds a rate struct for emitFreeRtosMain test inputs.
%   Returns a scalar struct with Index, PeriodSeconds, OffsetSeconds 0, StepFunction,
%   Priority, and TaskName fields matching the emitter's expected schema.
%
%   Syntax:
%       rate = makeRate(index, periodSeconds, stepFunction, priority, taskName)
%
%   Inputs:
%       index - numeric rate index.
%       periodSeconds - numeric sample period in seconds.
%       stepFunction - char or string step function name.
%       priority - numeric FreeRTOS priority offset.
%       taskName - char or string task name.
%
%   Outputs:
%       rate - scalar struct describing one sample-rate task.
%
%   Example:
%       rate = makeRate(0, 0.01, "demo_step0", 2, "rate0");
%
%   See also: TEMITFREERTOSMAIN
    rate = struct( ...
        "Index", index, ...
        "PeriodSeconds", periodSeconds, ...
        "OffsetSeconds", 0, ...
        "StepFunction", string(stepFunction), ...
        "Priority", priority, ...
        "TaskName", string(taskName));
end
