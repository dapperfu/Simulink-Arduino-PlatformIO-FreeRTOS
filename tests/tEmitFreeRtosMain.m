classdef tEmitFreeRtosMain < matlab.unittest.TestCase
    % Tests for FreeRTOS main generation from sample rates.

    methods (TestClassSetup)
        function addRepoToPath(testCase)
            testsFolder = fileparts(mfilename("fullpath"));
            repoRoot = fileparts(testsFolder);
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture(repoRoot));
        end
    end

    methods (Test)
        function createsOneTaskPerRate(testCase)
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
    rate = struct( ...
        "Index", index, ...
        "PeriodSeconds", periodSeconds, ...
        "OffsetSeconds", 0, ...
        "StepFunction", string(stepFunction), ...
        "Priority", priority, ...
        "TaskName", string(taskName));
end
