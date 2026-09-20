classdef (Sealed) I2cWrite < matlab.System & coder.ExternalDependency
    %I2cWrite Write bytes to an I2C slave. Uno uses SDA on A4 and SCL on A5.

    properties (Nontunable)
        SlaveAddress (1,1) {mustBeInteger, mustBeNonnegative} = 8
        HasRegister (1,1) logical = true
        RegisterAddress (1,1) {mustBeInteger, mustBeNonnegative} = 0
        SampleTime (1,1) double = -1
    end

    methods
        function obj = I2cWrite(varargin)
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

        function stepImpl(obj, u)
            if coder.target("Rtw")
                data = uint8(u(:));
                coder.ceval("arduinopioI2cWrite", uint8(obj.SlaveAddress), uint8(obj.HasRegister), ...
                    uint8(obj.RegisterAddress), coder.rref(data), uint8(numel(data)));
            end
        end

        function num = getNumInputsImpl(~)
            num = 1;
        end

        function num = getNumOutputsImpl(~)
            num = 0;
        end

        function icon = getIconImpl(~)
            icon = "I2C Write";
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
            name = "Arduino PIO I2C Write";
        end

        function tf = isSupportedContext(context)
            tf = context.isCodeGenTarget("rtw");
        end

        function updateBuildInfo(buildInfo, context)
            arduinopio.updateDriverBuildInfo(buildInfo, context, "arduinopio_i2c.cpp");
        end
    end
end
