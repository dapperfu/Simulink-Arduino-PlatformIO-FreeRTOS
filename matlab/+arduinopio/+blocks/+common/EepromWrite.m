classdef (Sealed) EepromWrite < matlab.System & coder.ExternalDependency
    %EepromWrite Write bytes to on-board EEPROM. Uno has 1024 bytes at addresses 0-1023.

    properties (Nontunable)
        StartAddress (1,1) {mustBeInteger, mustBeNonnegative} = 0
        SampleTime (1,1) double = -1
    end

    methods
        function obj = EepromWrite(varargin)
            coder.allowpcode("plain");
            setProperties(obj, nargin, varargin{:});
        end
    end

    methods (Access = protected)
        function validatePropertiesImpl(obj)
            arduinopio.validateEepromRange(obj.StartAddress, 1);
        end

        function setupImpl(~)
            if coder.target("Rtw")
                coder.cinclude("arduinopio_eeprom.h");
                coder.ceval("arduinopioEepromSetup");
            end
        end

        function stepImpl(obj, u)
            if coder.target("Rtw")
                data = uint8(u(:));
                coder.ceval("arduinopioEepromWrite", uint16(obj.StartAddress), coder.rref(data), uint8(numel(data)));
            end
        end

        function num = getNumInputsImpl(~)
            num = 1;
        end

        function num = getNumOutputsImpl(~)
            num = 0;
        end

        function icon = getIconImpl(~)
            icon = "EEPROM Write";
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
            name = "Arduino PIO EEPROM Write";
        end

        function tf = isSupportedContext(context)
            tf = context.isCodeGenTarget("rtw");
        end

        function updateBuildInfo(buildInfo, context)
            arduinopio.updateDriverBuildInfo(buildInfo, context, "arduinopio_eeprom.cpp");
        end
    end
end
