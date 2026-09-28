classdef (Sealed) SpiWriteRead < matlab.System & coder.ExternalDependency
    %SpiWriteRead Full-duplex SPI transfer. Uno uses SS=10, MOSI=11, MISO=12, SCK=13.

    properties (Nontunable)
        ChipSelectPin (1,1) {mustBeInteger, mustBeNonnegative} = 10
        ClockHz (1,1) {mustBeInteger, mustBePositive} = 4000000
        SpiMode (1,1) {mustBeInteger, mustBeMember(SpiMode, [0, 1, 2, 3])} = 0
        MsbFirst (1,1) logical = true
        SampleTime (1,1) double = -1
    end

    methods
        function obj = SpiWriteRead(varargin)
            coder.allowpcode("plain");
            setProperties(obj, nargin, varargin{:});
        end
    end

    methods (Access = protected)
        function validatePropertiesImpl(obj)
            arduinopio.validatePin(obj.ChipSelectPin, "digital");
        end

        function setupImpl(obj)
            if coder.target("Rtw")
                coder.cinclude("arduinopio_spi.h");
                coder.ceval("arduinopioSpiSetup", uint8(obj.ChipSelectPin), uint32(obj.ClockHz), ...
                    uint8(obj.SpiMode), uint8(obj.MsbFirst));
            end
        end

        function y = stepImpl(obj, u)
            tx = uint8(u(:));
            y = tx;
            if coder.target("Rtw")
                y = zeros(size(tx), "uint8");
                coder.ceval("arduinopioSpiWriteRead", uint8(obj.ChipSelectPin), coder.rref(tx), ...
                    coder.wref(y), uint8(numel(tx)));
            end
        end

        function num = getNumInputsImpl(~)
            num = 1;
        end

        function num = getNumOutputsImpl(~)
            num = 1;
        end

        function sz = getOutputSizeImpl(obj)
            sz = propagatedInputSize(obj, 1);
        end

        function dt = getOutputDataTypeImpl(~)
            dt = "uint8";
        end

        function c = isOutputComplexImpl(~)
            c = false;
        end

        function f = isOutputFixedSizeImpl(obj)
            f = propagatedInputFixedSize(obj, 1);
        end

        function icon = getIconImpl(obj)
            icon = arduinopio.iconWithPin("SPI WriteRead", obj.ChipSelectPin, Label="CS");
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
            name = "Arduino PIO SPI WriteRead";
        end

        function tf = isSupportedContext(context)
            tf = context.isCodeGenTarget("rtw");
        end

        function updateBuildInfo(buildInfo, context)
            arduinopio.updateDriverBuildInfo(buildInfo, context, "arduinopio_spi.cpp");
        end
    end
end
