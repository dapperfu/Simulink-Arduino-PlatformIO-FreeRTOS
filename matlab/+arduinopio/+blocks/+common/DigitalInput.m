classdef (Sealed) DigitalInput < matlab.System & coder.ExternalDependency
    %DigitalInput Read the logical state of an Arduino digital input pin.
    %   The Common library block uses the Level-2 MATLAB S-function
    %   arduinopio_digital_input instead of this System object.

    properties (Nontunable)
        Pin (1,1) {mustBeInteger, mustBeNonnegative} = 2
        EnablePullup (1,1) logical = false
        SampleTime (1,1) double = -1
    end

    methods
        function obj = DigitalInput(varargin)
            coder.allowpcode("plain");
            setProperties(obj, nargin, varargin{:});
        end
    end

    methods (Access = protected)
        function validatePropertiesImpl(obj)
            arduinopio.validatePin(obj.Pin, "digital");
        end

        function setupImpl(obj)
            if coder.target("Rtw")
                coder.cinclude("arduinopio_gpio.h");
                coder.ceval("arduinopioDigitalInputSetup", uint8(obj.Pin), uint8(obj.EnablePullup));
            end
        end

        function y = stepImpl(obj)
            y = false;
            if coder.target("Rtw")
                value = uint8(0);
                value = coder.ceval("arduinopioDigitalRead", uint8(obj.Pin));
                y = (value ~= 0);
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
            out = "logical";
        end

        function out = isOutputComplexImpl(~)
            out = false;
        end

        function out = isOutputFixedSizeImpl(~)
            out = true;
        end

        function icon = getIconImpl(~)
            icon = "Digital Input";
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
            name = "Arduino PIO Digital Input";
        end

        function tf = isSupportedContext(context)
            tf = context.isCodeGenTarget("rtw");
        end

        function updateBuildInfo(buildInfo, context)
            arduinopio.updateDriverBuildInfo(buildInfo, context, "arduinopio_gpio.cpp");
        end
    end

    methods (Static, Access = protected)
        function header = getHeaderImpl()
            header = matlab.system.display.Header( ...
                "arduinopio.blocks.common.DigitalInput", ...
                Title="Digital Input", ...
                Text="Read a digital pin. Uno pins 0-13 and A0-A5 (14-19) are valid.");
        end
    end
end
