classdef (Sealed) EepromRead < matlab.System & coder.ExternalDependency
    %EepromRead Read bytes from on-board EEPROM. Uno has 1024 bytes at addresses 0-1023.

    properties (Nontunable)
        StartAddress (1,1) {mustBeInteger, mustBeNonnegative} = 0
        DataLength (1,1) {mustBeInteger, mustBePositive} = 1
        SampleTime (1,1) double = -1
    end

    methods
        function obj = EepromRead(varargin)
            coder.allowpcode("plain");
            setProperties(obj, nargin, varargin{:});
        end
    end

    methods (Access = protected)
        function validatePropertiesImpl(obj)
            info = arduinopio.boards.getBoard();
            lastAddress = obj.StartAddress + obj.DataLength - 1;
            if lastAddress >= info.EepromSize
                error("arduinopio:EepromRange", ...
                    "EEPROM read [%d:%d] exceeds %s size %d. Use a start address and length that fit.", ...
                    obj.StartAddress, lastAddress, info.DisplayName, info.EepromSize);
            end
        end

        function setupImpl(~)
            if coder.target("Rtw")
                coder.cinclude("arduinopio_eeprom.h");
                coder.ceval("arduinopioEepromSetup");
            end
        end

        function data = stepImpl(obj)
            data = zeros(obj.DataLength, 1, "uint8");
            if coder.target("Rtw")
                coder.ceval("arduinopioEepromRead", uint16(obj.StartAddress), coder.wref(data), uint8(obj.DataLength));
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
            icon = "EEPROM Read";
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
            name = "Arduino PIO EEPROM Read";
        end

        function tf = isSupportedContext(context)
            tf = context.isCodeGenTarget("rtw");
        end

        function updateBuildInfo(buildInfo, context)
            arduinopio.updateDriverBuildInfo(buildInfo, context, "arduinopio_eeprom.cpp");
        end
    end
end
