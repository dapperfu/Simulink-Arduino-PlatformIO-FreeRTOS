classdef (Sealed) AnalogInputAvr < matlab.System & coder.ExternalDependency
    %AnalogInputAvr Read the AVR ADC with explicit reference and prescaler.

    properties (Nontunable)
        Pin (1,1) {mustBeInteger, mustBeNonnegative} = 0
        ReferenceSelect (1,1) {mustBeInteger, mustBeMember(ReferenceSelect, [0, 1, 3])} = 1
        PrescalerSelect (1,1) {mustBeInteger, mustBeMember(PrescalerSelect, 1:7)} = 7
        SampleTime (1,1) double = -1
    end

    methods
        function obj = AnalogInputAvr(varargin)
            coder.allowpcode("plain");
            setProperties(obj, nargin, varargin{:});
        end
    end

    methods (Access = protected)
        function validatePropertiesImpl(obj)
            arduinopio.validatePin(obj.Pin, "analog");
        end

        function setupImpl(obj)
            if coder.target("Rtw")
                coder.cinclude("arduinopio_adc_avr.h");
                coder.ceval("arduinopioAdcAvrSetup", uint8(obj.Pin), uint8(obj.ReferenceSelect), ...
                    uint8(obj.PrescalerSelect));
            end
        end

        function y = stepImpl(obj)
            y = uint16(0);
            if coder.target("Rtw")
                y = coder.ceval("arduinopioAdcAvrRead", uint8(obj.Pin));
            end
        end

        function num = getNumInputsImpl(~)
            num = 0;
        end

        function num = getNumOutputsImpl(~)
            num = 1;
        end

        function sz = getOutputSizeImpl(~)
            sz = [1, 1];
        end

        function dt = getOutputDataTypeImpl(~)
            dt = "uint16";
        end

        function c = isOutputComplexImpl(~)
            c = false;
        end

        function f = isOutputFixedSizeImpl(~)
            f = true;
        end

        function icon = getIconImpl(~)
            icon = "Analog Input AVR";
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
            name = "Arduino PIO Analog Input AVR";
        end

        function tf = isSupportedContext(context)
            tf = context.isCodeGenTarget("rtw");
        end

        function updateBuildInfo(buildInfo, context)
            arduinopio.updateDriverBuildInfo(buildInfo, context, "arduinopio_adc_avr.cpp");
        end
    end

    methods (Static, Access = protected)
        function header = getHeaderImpl()
            header = matlab.system.display.Header( ...
                "arduinopio.blocks.avr.AnalogInputAvr", ...
                Title="Analog Input AVR", ...
                Text="ReferenceSelect: 0=AREF, 1=AVcc, 3=internal 1.1 V. PrescalerSelect 1-7 maps to /2../128.");
        end
    end
end
