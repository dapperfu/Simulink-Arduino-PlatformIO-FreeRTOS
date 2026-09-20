classdef (Sealed) AnalogInput < matlab.System & coder.ExternalDependency
    %AnalogInput Measure voltage on an Arduino analog input pin as a 10-bit count.
    %   The Common library block uses the Level-2 MATLAB S-function
    %   arduinopio_analog_input instead of this System object.

    properties (Nontunable)
        Pin (1,1) {mustBeInteger, mustBeNonnegative} = 0
        SampleTime (1,1) double = -1
    end

    methods
        function obj = AnalogInput(varargin)
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
                coder.cinclude("arduinopio_adc.h");
                coder.ceval("arduinopioAnalogSetup", uint8(obj.Pin));
            end
        end

        function y = stepImpl(obj)
            y = uint16(0);
            if coder.target("Rtw")
                y = coder.ceval("arduinopioAnalogRead", uint8(obj.Pin));
            end
        end

        function num = getNumInputsImpl(~)
            num = 0;
        end

        function num = getNumOutputsImpl(~)
            num = 1;
        end

        function out = getOutputSizeImpl(~)
            out = [1, 1];
        end

        function out = getOutputDataTypeImpl(~)
            out = "uint16";
        end

        function out = isOutputComplexImpl(~)
            out = false;
        end

        function out = isOutputFixedSizeImpl(~)
            out = true;
        end

        function icon = getIconImpl(~)
            icon = "Analog Input";
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
            name = "Arduino PIO Analog Input";
        end

        function tf = isSupportedContext(context)
            tf = context.isCodeGenTarget("rtw");
        end

        function updateBuildInfo(buildInfo, context)
            arduinopio.updateDriverBuildInfo(buildInfo, context, "arduinopio_adc.cpp");
        end
    end

    methods (Static, Access = protected)
        function header = getHeaderImpl()
            header = matlab.system.display.Header( ...
                "arduinopio.blocks.common.AnalogInput", ...
                Title="Analog Input", ...
                Text="Uno A0-A5 as pin 0-5. Output is 0-1023 for a 10-bit ADC.");
        end
    end
end
