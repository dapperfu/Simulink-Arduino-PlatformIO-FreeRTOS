classdef (Sealed) ContinuousServoWrite < matlab.System & coder.ExternalDependency
    %ContinuousServoWrite Set continuous-rotation servo speed from -100 to 100. Uses Timer1 on Uno.

    properties (Nontunable)
        Pin (1,1) {mustBeInteger, mustBeNonnegative} = 9
        SampleTime (1,1) double = -1
    end

    methods
        function obj = ContinuousServoWrite(varargin)
            coder.allowpcode("plain");
            setProperties(obj, nargin, varargin{:});
        end
    end

    methods (Access = protected)
        function validatePropertiesImpl(obj)
            arduinopio.validatePin(obj.Pin, "digital");
            arduinopio.warnIfNotLibrary("arduinopio:Timer1Conflict", ...
                "Continuous Servo Write uses Timer1. Avoid PWM on pins 9 and 10 and Input Capture on pin 8.");
        end

        function setupImpl(obj)
            if coder.target("Rtw")
                coder.cinclude("arduinopio_servo.h");
                coder.ceval("arduinopioServoSetup", uint8(obj.Pin));
            end
        end

        function stepImpl(obj, u)
            if coder.target("Rtw")
                speed = int8(min(max(double(u), -100), 100));
                coder.ceval("arduinopioServoWriteSpeed", uint8(obj.Pin), speed);
            end
        end

        function num = getNumInputsImpl(~)
            num = 1;
        end

        function num = getNumOutputsImpl(~)
            num = 0;
        end

        function icon = getIconImpl(~)
            icon = "Continuous Servo Write";
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
            name = "Arduino PIO Continuous Servo Write";
        end

        function tf = isSupportedContext(context)
            tf = context.isCodeGenTarget("rtw");
        end

        function updateBuildInfo(buildInfo, context)
            arduinopio.updateDriverBuildInfo(buildInfo, context, "arduinopio_servo.cpp", "Servo");
        end
    end
end
