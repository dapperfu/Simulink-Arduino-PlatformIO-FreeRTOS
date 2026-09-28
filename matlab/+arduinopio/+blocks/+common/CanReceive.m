classdef (Sealed) CanReceive < matlab.System & coder.ExternalDependency
    %CanReceive Read a CAN 2.0 frame from an MCP2515 controller on SPI.

    properties (Nontunable)
        ChipSelectPin (1,1) {mustBeInteger, mustBeNonnegative} = 10
        OscillatorMHz (1,1) {mustBeMember(OscillatorMHz, [8, 16, 20])} = 8
        BaudRateKbps (1,1) {mustBeMember(BaudRateKbps, [125, 250, 500, 1000])} = 500
        OperatingMode (1,1) {mustBeInteger, mustBeMember(OperatingMode, [0, 1, 2])} = 0
        UseFilter (1,1) logical = false
        FilterId (1,1) {mustBeInteger, mustBeNonnegative} = 0
        FilterMask (1,1) {mustBeInteger, mustBeNonnegative} = 2047
        FilterExtended (1,1) logical = false
        SampleTime (1,1) double = -1
    end

    methods
        function obj = CanReceive(varargin)
            coder.allowpcode("plain");
            setProperties(obj, nargin, varargin{:});
        end
    end

    methods (Access = protected)
        function validatePropertiesImpl(obj)
            arduinopio.validatePin(obj.ChipSelectPin, "digital");
            arduinopio.validateCanIdentifier(obj.FilterId, obj.FilterExtended, "FilterId");
            arduinopio.validateCanIdentifier(obj.FilterMask, obj.FilterExtended, "FilterMask");
        end

        function setupImpl(obj)
            if coder.target("Rtw")
                coder.cinclude("arduinopio_can.h");
                coder.ceval("arduinopioCanSetup", uint8(obj.ChipSelectPin), uint16(obj.BaudRateKbps), ...
                    uint8(obj.OscillatorMHz), uint8(obj.OperatingMode));
                if obj.UseFilter
                    coder.ceval("arduinopioCanSetFilter", uint8(obj.FilterExtended), ...
                        uint32(obj.FilterId), uint32(obj.FilterMask));
                end
            end
        end

        function [identifier, data, length, status] = stepImpl(~)
            identifier = uint32(0);
            data = zeros(8, 1, "uint8");
            length = uint8(0);
            status = false;
            if coder.target("Rtw")
                extended = uint8(0);
                remote = uint8(0);
                gotFrame = uint8(0);
                gotFrame = coder.ceval("arduinopioCanReceive", coder.wref(identifier), coder.wref(extended), ...
                    coder.wref(remote), coder.wref(data), coder.wref(length));
                status = (gotFrame ~= 0);
            end
        end

        function num = getNumInputsImpl(~)
            num = 0;
        end

        function names = getOutputNamesImpl(~)
            names = ["Id", "Data", "Length", "Status"];
        end

        function num = getNumOutputsImpl(~)
            num = 4;
        end

        function [sz1, sz2, sz3, sz4] = getOutputSizeImpl(~)
            sz1 = [1, 1];
            sz2 = [8, 1];
            sz3 = [1, 1];
            sz4 = [1, 1];
        end

        function [dt1, dt2, dt3, dt4] = getOutputDataTypeImpl(~)
            dt1 = "uint32";
            dt2 = "uint8";
            dt3 = "uint8";
            dt4 = "logical";
        end

        function [c1, c2, c3, c4] = isOutputComplexImpl(~)
            c1 = false;
            c2 = false;
            c3 = false;
            c4 = false;
        end

        function [f1, f2, f3, f4] = isOutputFixedSizeImpl(~)
            f1 = true;
            f2 = true;
            f3 = true;
            f4 = true;
        end

        function icon = getIconImpl(obj)
            icon = arduinopio.iconWithPin("CAN Receive", obj.ChipSelectPin, Label="CS");
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
            name = "Arduino PIO CAN Receive";
        end

        function tf = isSupportedContext(context)
            tf = context.isCodeGenTarget("rtw");
        end

        function updateBuildInfo(buildInfo, context)
            arduinopio.updateDriverBuildInfo(buildInfo, context, "arduinopio_can.cpp", "MCP2515");
        end
    end

    methods (Static, Access = protected)
        function header = getHeaderImpl()
            header = matlab.system.display.Header( ...
                "arduinopio.blocks.common.CanReceive", ...
                Title="CAN Receive", ...
                Text="Polls MCP2515 over SPI each sample. Status is true when a new frame is read. UseFilter programs MASK/RXF when selected.");
        end
    end
end
