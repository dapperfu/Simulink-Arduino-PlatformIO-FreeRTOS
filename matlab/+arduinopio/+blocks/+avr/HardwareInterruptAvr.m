classdef (Sealed) HardwareInterruptAvr < matlab.System & coder.ExternalDependency
    %HardwareInterruptAvr Detect an AVR peripheral interrupt. Output is true when an event is pending.

    properties (Nontunable)
        SourceId (1,1) {mustBeInteger, mustBeMember(SourceId, [0, 1, 2, 3])} = 0
        SampleTime (1,1) double = -1
    end

    methods
        function obj = HardwareInterruptAvr(varargin)
            coder.allowpcode("plain");
            setProperties(obj, nargin, varargin{:});
        end
    end

    methods (Access = protected)
        function setupImpl(obj)
            if coder.target("Rtw")
                coder.cinclude("arduinopio_hwint_avr.h");
                coder.ceval("arduinopioHwIntAvrSetup", uint8(obj.SourceId));
            end
        end

        function y = stepImpl(obj, simIrq)
            if coder.target("Rtw")
                pending = uint8(0);
                pending = coder.ceval("arduinopioHwIntAvrTake", uint8(obj.SourceId));
                y = (pending ~= 0);
            else
                y = logical(simIrq);
            end
        end

        function num = getNumInputsImpl(~)
            num = 1;
        end

        function num = getNumOutputsImpl(~)
            num = 1;
        end

        function sz = getOutputSizeImpl(~)
            sz = [1, 1];
        end

        function dt = getOutputDataTypeImpl(~)
            dt = "logical";
        end

        function c = isOutputComplexImpl(~)
            c = false;
        end

        function f = isOutputFixedSizeImpl(~)
            f = true;
        end

        function icon = getIconImpl(~)
            icon = "Hardware Interrupt AVR";
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
            name = "Arduino PIO Hardware Interrupt AVR";
        end

        function tf = isSupportedContext(context)
            tf = context.isCodeGenTarget("rtw");
        end

        function updateBuildInfo(buildInfo, context)
            arduinopio.updateDriverBuildInfo(buildInfo, context, "arduinopio_hwint_avr.cpp");
        end
    end

    methods (Static, Access = protected)
        function header = getHeaderImpl()
            header = matlab.system.display.Header( ...
                "arduinopio.blocks.avr.HardwareInterruptAvr", ...
                Title="Hardware Interrupt AVR", ...
                Text="0=Timer1 overflow, 1=Timer1 compare A, 2=Timer2 overflow, 3=ADC complete. Timer0 and USART RX stay with the Arduino core.");
        end
    end
end
