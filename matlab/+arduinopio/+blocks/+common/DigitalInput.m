classdef (Sealed) DigitalInput < matlab.System & coder.ExternalDependency
    %DigitalInput Read the logical state of an Arduino digital input pin.
    %   The Common library block uses the Level-2 MATLAB S-function
    %   arduinopio_digital_input instead of this System object.

    properties (Nontunable)
        Pin (1,1) {mustBeInteger, mustBeNonnegative} = 2
        % Internal resistor
        PinPull = 'None'
        SampleTime (1,1) double = -1
        SimValue (1,1) double = 0
    end

    properties (Constant, Hidden)
        PinPullSet = matlab.system.StringSet({'None', 'Pull-up', 'Pull-down'})
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
            arduinopio.validatePinPull(obj.PinPull);
        end

        function setupImpl(obj)
            if coder.target("Rtw")
                coder.cinclude("arduinopio_arduino.h");
                pullName = char(obj.PinPull);
                if strcmp(pullName, "Pull-up")
                    coder.ceval("pinMode", uint8(obj.Pin), coder.opaque("uint8_t", "INPUT_PULLUP"));
                elseif strcmp(pullName, "Pull-down")
                    coder.ceval("pinMode", uint8(obj.Pin), coder.opaque("uint8_t", "INPUT_PULLDOWN"));
                else
                    coder.ceval("pinMode", uint8(obj.Pin), coder.opaque("uint8_t", "INPUT"));
                end
            end
        end

        function y = stepImpl(obj)
            y = logical(obj.SimValue ~= 0);
            if coder.target("Rtw")
                value = int32(0);
                coder.cinclude("arduinopio_arduino.h");
                value = coder.ceval("digitalRead", uint8(obj.Pin));
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

        function icon = getIconImpl(obj)
            icon = arduinopio.iconWithPin("Digital Input", obj.Pin);
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
            arduinopio.updateDriverBuildInfo(buildInfo, context);
        end
    end

    methods (Static, Access = protected)
        function header = getHeaderImpl()
            header = matlab.system.display.Header( ...
                "arduinopio.blocks.common.DigitalInput", ...
                Title="Digital Input", ...
                Text="MATLAB System object path: setupImpl/stepImpl emit coder.ceval calls. Internal resistor: None, Pull-up, or Pull-down.");
        end
    end
end
