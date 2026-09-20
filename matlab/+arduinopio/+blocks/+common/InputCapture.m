classdef (Sealed) InputCapture < matlab.System & coder.ExternalDependency
    %InputCapture Measure frequency and duty cycle. Uno input capture is ICP1 on pin 8 (Timer1).

    properties (Nontunable)
        Pin (1,1) {mustBeInteger, mustBeNonnegative} = 8
        SampleTime (1,1) double = -1
    end

    methods
        function obj = InputCapture(varargin)
            coder.allowpcode("plain");
            setProperties(obj, nargin, varargin{:});
        end
    end

    methods (Access = protected)
        function validatePropertiesImpl(obj)
            arduinopio.validatePin(obj.Pin, "capture");
            arduinopio.warnIfNotLibrary("arduinopio:Timer1Conflict", ...
                "Input Capture on pin %d uses Timer1. Avoid PWM on pins 9 and 10 and Servo blocks.", obj.Pin);
        end

        function setupImpl(obj)
            if coder.target("Rtw")
                coder.cinclude("arduinopio_capture.h");
                coder.ceval("arduinopioCaptureSetup", uint8(obj.Pin));
            end
        end

        function [frequencyHz, dutyCycle] = stepImpl(~)
            frequencyHz = single(0);
            dutyCycle = single(0);
            if coder.target("Rtw")
                coder.ceval("arduinopioCaptureRead", coder.wref(frequencyHz), coder.wref(dutyCycle));
            end
        end

        function num = getNumInputsImpl(~)
            num = 0;
        end

        function num = getNumOutputsImpl(~)
            num = 2;
        end

        function [sz1, sz2] = getOutputSizeImpl(~)
            sz1 = [1, 1];
            sz2 = [1, 1];
        end

        function [dt1, dt2] = getOutputDataTypeImpl(~)
            dt1 = "single";
            dt2 = "single";
        end

        function [c1, c2] = isOutputComplexImpl(~)
            c1 = false;
            c2 = false;
        end

        function [f1, f2] = isOutputFixedSizeImpl(~)
            f1 = true;
            f2 = true;
        end

        function icon = getIconImpl(~)
            icon = "Input Capture";
        end

        function sts = getSampleTimeImpl(obj)
            if obj.SampleTime == -1
                sts = createSampleTime(obj, Type="Inherited");
            else
                sts = createSampleTime(obj, Type="Discrete", SampleTime=obj.SampleTime);
            end
        end
    end

    methods (Static)
        function name = getDescriptiveName(~)
            name = "Arduino PIO Input Capture";
        end

        function tf = isSupportedContext(context)
            tf = context.isCodeGenTarget("rtw");
        end

        function updateBuildInfo(buildInfo, context)
            arduinopio.updateDriverBuildInfo(buildInfo, context, "arduinopio_capture.cpp");
        end
    end
end
