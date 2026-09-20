classdef (Sealed) StandardServoWrite < matlab.System & coder.ExternalDependency
    %StandardServoWrite Set a standard servo shaft angle in degrees. Uses Timer1 on Uno.

    properties (Nontunable)
        Pin (1,1) {mustBeInteger, mustBeNonnegative} = 9
        SampleTime (1,1) double = -1
    end

    methods
        function obj = StandardServoWrite(varargin)
            coder.allowpcode("plain");
            setProperties(obj, nargin, varargin{:});
        end
    end

    methods (Access = protected)
        function validatePropertiesImpl(obj)
            arduinopio.validatePin(obj.Pin, "digital");
            arduinopio.warnIfNotLibrary("arduinopio:Timer1Conflict", ...
                "Standard Servo Write uses Timer1. Avoid PWM on pins 9 and 10 and Input Capture on pin 8.");
        end

        function setupImpl(obj)
            if coder.target("Rtw")
                coder.cinclude("arduinopio_servo.h");
                coder.ceval("arduinopioServoSetup", uint8(obj.Pin));
            end
        end

        function stepImpl(obj, u)
            if coder.target("Rtw")
                angleDeg = uint8(min(max(double(u), 0), 180));
                coder.ceval("arduinopioServoWriteAngle", uint8(obj.Pin), angleDeg);
            end
        end

        function num = getNumInputsImpl(~)
            num = 1;
        end

        function num = getNumOutputsImpl(~)
            num = 0;
        end

        function icon = getIconImpl(~)
            icon = "Standard Servo Write";
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
            name = "Arduino PIO Standard Servo Write";
        end

        function tf = isSupportedContext(context)
            tf = context.isCodeGenTarget("rtw");
        end

        function updateBuildInfo(buildInfo, context)
            arduinopio.updateDriverBuildInfo(buildInfo, context, "arduinopio_servo.cpp", "Servo");
        end
    end
end
