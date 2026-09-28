classdef (Sealed) Pwm < matlab.System & coder.ExternalDependency
    %Pwm Generate PWM on an Arduino analog-write pin. Duty cycle input is 0-255.

    properties (Nontunable)
        Pin (1,1) {mustBeInteger, mustBeNonnegative} = 5
        SampleTime (1,1) double = -1
    end

    methods
        function obj = Pwm(varargin)
            coder.allowpcode("plain");
            setProperties(obj, nargin, varargin{:});
        end
    end

    methods (Access = protected)
        function validatePropertiesImpl(obj)
            arduinopio.validatePin(obj.Pin, "pwm");
            arduinopio.warnTimerConflict(obj.Pin, "PWM");
        end

        function setupImpl(obj)
            if coder.target("Rtw")
                coder.cinclude("arduinopio_arduino.h");
                coder.ceval("pinMode", uint8(obj.Pin), coder.opaque("uint8_t", "OUTPUT"));
                coder.ceval("analogWrite", uint8(obj.Pin), int32(0));
            end
        end

        function stepImpl(obj, u)
            if coder.target("Rtw")
                duty = int32(min(max(double(u), 0), 255));
                coder.cinclude("arduinopio_arduino.h");
                coder.ceval("analogWrite", uint8(obj.Pin), duty);
            end
        end

        function num = getNumInputsImpl(~)
            num = 1;
        end

        function num = getNumOutputsImpl(~)
            num = 0;
        end

        function flag = isInputSizeMutableImpl(~, ~)
            flag = false;
        end

        function icon = getIconImpl(obj)
            icon = arduinopio.iconWithPin("PWM", obj.Pin);
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
            name = "Arduino PIO PWM";
        end

        function tf = isSupportedContext(context)
            tf = context.isCodeGenTarget("rtw");
        end

        function updateBuildInfo(buildInfo, context)
            arduinopio.updateDriverBuildInfo(buildInfo, context);
        end
    end

    methods (Static, Access = protected)
        function header = getHeaderImpl()
            header = matlab.system.display.Header( ...
                "arduinopio.blocks.common.Pwm", ...
                Title="PWM", ...
                Text="Uno PWM pins: 3, 5, 6, 9, 10, 11. Pins 9 and 10 share Timer1 with Servo and Input Capture.");
        end
    end
end
