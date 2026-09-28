classdef (Sealed) PwmAvr < matlab.System & coder.ExternalDependency
    %PwmAvr PWM with AVR timer mode and prescaler control.

    properties (Nontunable)
        Pin (1,1) {mustBeInteger, mustBeNonnegative} = 5
        PrescalerSelect (1,1) {mustBeInteger, mustBeMember(PrescalerSelect, 1:5)} = 3
        FastPwm (1,1) logical = true
        SampleTime (1,1) double = -1
    end

    methods
        function obj = PwmAvr(varargin)
            coder.allowpcode("plain");
            setProperties(obj, nargin, varargin{:});
        end
    end

    methods (Access = protected)
        function validatePropertiesImpl(obj)
            arduinopio.validatePin(obj.Pin, "pwm");
            arduinopio.warnTimerConflict(obj.Pin, "PWM AVR");
        end

        function setupImpl(obj)
            if coder.target("Rtw")
                timerId = uint8(2);
                if (obj.Pin == 5) || (obj.Pin == 6)
                    timerId = uint8(0);
                elseif (obj.Pin == 9) || (obj.Pin == 10)
                    timerId = uint8(1);
                end
                coder.cinclude("arduinopio_pwm_avr.h");
                coder.ceval("arduinopioPwmAvrSetup", uint8(obj.Pin), timerId, ...
                    uint8(obj.PrescalerSelect), uint8(obj.FastPwm));
            end
        end

        function stepImpl(obj, u)
            if coder.target("Rtw")
                duty = uint8(min(max(double(u), 0), 255));
                coder.ceval("arduinopioPwmAvrWrite", uint8(obj.Pin), duty);
            end
        end

        function num = getNumInputsImpl(~)
            num = 1;
        end

        function num = getNumOutputsImpl(~)
            num = 0;
        end

        function icon = getIconImpl(obj)
            icon = arduinopio.iconWithPin("PWM AVR", obj.Pin);
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
            name = "Arduino PIO PWM AVR";
        end

        function tf = isSupportedContext(context)
            tf = context.isCodeGenTarget("rtw");
        end

        function updateBuildInfo(buildInfo, context)
            arduinopio.updateDriverBuildInfo(buildInfo, context, "arduinopio_pwm_avr.cpp");
        end
    end

    methods (Static, Access = protected)
        function header = getHeaderImpl()
            header = matlab.system.display.Header( ...
                "arduinopio.blocks.avr.PwmAvr", ...
                Title="PWM AVR", ...
                Text="PrescalerSelect 1-5 maps to /1,/8,/64,/256,/1024. Pins 9 and 10 share Timer1 with Servo and Input Capture.");
        end
    end
end
