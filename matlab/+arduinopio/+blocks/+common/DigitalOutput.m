classdef (Sealed) DigitalOutput < matlab.System & coder.ExternalDependency
    %DigitalOutput Set the logical state of an Arduino digital output pin.
    %   The Common library block uses the Level-2 MATLAB S-function
    %   arduinopio_digital_output instead of this System object.

    properties (Nontunable)
        Pin (1,1) {mustBeInteger, mustBeNonnegative} = 13
        SampleTime (1,1) double = -1
    end

    methods
        function obj = DigitalOutput(varargin)
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
                coder.cinclude("arduinopio_arduino.h");
                coder.ceval("pinMode", uint8(obj.Pin), coder.opaque("uint8_t", "OUTPUT"));
            end
        end

        function stepImpl(obj, u)
            if coder.target("Rtw")
                coder.cinclude("arduinopio_arduino.h");
                if u ~= 0
                    coder.ceval("digitalWrite", uint8(obj.Pin), coder.opaque("uint8_t", "HIGH"));
                else
                    coder.ceval("digitalWrite", uint8(obj.Pin), coder.opaque("uint8_t", "LOW"));
                end
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
            icon = arduinopio.iconWithPin("Digital Output", obj.Pin);
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
            name = "Arduino PIO Digital Output";
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
                "arduinopio.blocks.common.DigitalOutput", ...
                Title="Digital Output", ...
                Text="MATLAB System object path: setupImpl/stepImpl emit coder.ceval pinMode/digitalWrite.");
        end
    end
end
