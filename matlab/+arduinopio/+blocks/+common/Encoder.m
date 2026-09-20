classdef (Sealed) Encoder < matlab.System & coder.ExternalDependency
    %Encoder Measure quadrature encoder ticks. Uno interrupt pins are 2 and 3.

    properties (Nontunable)
        PinA (1,1) {mustBeInteger, mustBeNonnegative} = 2
        PinB (1,1) {mustBeInteger, mustBeNonnegative} = 3
        ResetEachSample (1,1) logical = false
        SampleTime (1,1) double = -1
    end

    methods
        function obj = Encoder(varargin)
            coder.allowpcode("plain");
            setProperties(obj, nargin, varargin{:});
        end
    end

    methods (Access = protected)
        function validatePropertiesImpl(obj)
            arduinopio.validatePin(obj.PinA, "interrupt");
            arduinopio.validatePin(obj.PinB, "interrupt");
            if obj.PinA == obj.PinB
                error("arduinopio:EncoderPins", ...
                    "Encoder pins A and B must be different. Use Uno interrupt pins 2 and 3.");
            end
        end

        function setupImpl(obj)
            if coder.target("Rtw")
                coder.cinclude("arduinopio_encoder.h");
                coder.ceval("arduinopioEncoderSetup", uint8(obj.PinA), uint8(obj.PinB));
            end
        end

        function y = stepImpl(obj)
            y = int32(0);
            if coder.target("Rtw")
                y = coder.ceval("arduinopioEncoderRead", uint8(obj.ResetEachSample));
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
            dt = "int32";
        end

        function c = isOutputComplexImpl(~)
            c = false;
        end

        function f = isOutputFixedSizeImpl(~)
            f = true;
        end

        function icon = getIconImpl(~)
            icon = "Encoder";
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
            name = "Arduino PIO Encoder";
        end

        function tf = isSupportedContext(context)
            tf = context.isCodeGenTarget("rtw");
        end

        function updateBuildInfo(buildInfo, context)
            arduinopio.updateDriverBuildInfo(buildInfo, context, "arduinopio_encoder.cpp");
        end
    end
end
