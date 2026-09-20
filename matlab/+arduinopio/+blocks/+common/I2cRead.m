classdef (Sealed) I2cRead < matlab.System & coder.ExternalDependency
    %I2cRead Read bytes from an I2C slave. Uno uses SDA on A4 and SCL on A5.

    properties (Nontunable)
        SlaveAddress (1,1) {mustBeInteger, mustBeNonnegative} = 8
        HasRegister (1,1) logical = true
        RegisterAddress (1,1) {mustBeInteger, mustBeNonnegative} = 0
        DataLength (1,1) {mustBeInteger, mustBePositive} = 1
        SampleTime (1,1) double = -1
    end

    methods
        function obj = I2cRead(varargin)
            coder.allowpcode("plain");
            setProperties(obj, nargin, varargin{:});
        end
    end

    methods (Access = protected)
        function setupImpl(~)
            if coder.target("Rtw")
                coder.cinclude("arduinopio_i2c.h");
                coder.ceval("arduinopioI2cSetup");
            end
        end

        function data = stepImpl(obj)
            data = zeros(obj.DataLength, 1, "uint8");
            if coder.target("Rtw")
                coder.ceval("arduinopioI2cRead", uint8(obj.SlaveAddress), uint8(obj.HasRegister), ...
                    uint8(obj.RegisterAddress), coder.wref(data), uint8(obj.DataLength));
            end
        end

        function num = getNumInputsImpl(~)
            num = 0;
        end

        function num = getNumOutputsImpl(~)
            num = 1;
        end

        function sz = getOutputSizeImpl(obj)
            sz = [obj.DataLength, 1];
        end

        function dt = getOutputDataTypeImpl(~)
            dt = "uint8";
        end

        function c = isOutputComplexImpl(~)
            c = false;
        end

        function f = isOutputFixedSizeImpl(~)
            f = true;
        end

        function icon = getIconImpl(~)
            icon = "I2C Read";
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
            name = "Arduino PIO I2C Read";
        end

        function tf = isSupportedContext(context)
            tf = context.isCodeGenTarget("rtw");
        end

        function updateBuildInfo(buildInfo, context)
            arduinopio.updateDriverBuildInfo(buildInfo, context, "arduinopio_i2c.cpp");
        end
    end
end
