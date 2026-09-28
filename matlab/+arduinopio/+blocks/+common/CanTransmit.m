classdef (Sealed) CanTransmit < matlab.System & coder.ExternalDependency
    %CanTransmit Send a CAN 2.0 frame through an MCP2515 controller on SPI.

    properties (Nontunable)
        ChipSelectPin (1,1) {mustBeInteger, mustBeNonnegative} = 10
        OscillatorMHz (1,1) {mustBeMember(OscillatorMHz, [8, 16, 20])} = 8
        BaudRateKbps (1,1) {mustBeMember(BaudRateKbps, [125, 250, 500, 1000])} = 500
        MessageId (1,1) {mustBeInteger, mustBeNonnegative} = 256
        ExtendedFrame (1,1) logical = false
        RemoteFrame (1,1) logical = false
        OperatingMode (1,1) {mustBeInteger, mustBeMember(OperatingMode, [0, 1, 2])} = 0
        SampleTime (1,1) double = -1
    end

    methods
        function obj = CanTransmit(varargin)
            coder.allowpcode("plain");
            setProperties(obj, nargin, varargin{:});
        end
    end

    methods (Access = protected)
        function validatePropertiesImpl(obj)
            arduinopio.validatePin(obj.ChipSelectPin, "digital");
            arduinopio.validateCanIdentifier(obj.MessageId, obj.ExtendedFrame, "MessageId");
        end

        function setupImpl(obj)
            if coder.target("Rtw")
                coder.cinclude("arduinopio_can.h");
                coder.ceval("arduinopioCanSetup", uint8(obj.ChipSelectPin), uint16(obj.BaudRateKbps), ...
                    uint8(obj.OscillatorMHz), uint8(obj.OperatingMode));
            end
        end

        function stepImpl(obj, u)
            if coder.target("Rtw")
                data = uint8(u(:));
                maxPayload = 8;
                if numel(data) > maxPayload
                    data = data(1:maxPayload);
                end
                coder.ceval("arduinopioCanSend", uint32(obj.MessageId), uint8(obj.ExtendedFrame), ...
                    uint8(obj.RemoteFrame), coder.rref(data), uint8(numel(data)));
            end
        end

        function names = getInputNamesImpl(~)
            names = "Data";
        end

        function num = getNumInputsImpl(~)
            num = 1;
        end

        function num = getNumOutputsImpl(~)
            num = 0;
        end

        function icon = getIconImpl(obj)
            icon = arduinopio.iconWithPin("CAN Transmit", obj.ChipSelectPin, Label="CS");
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
            name = "Arduino PIO CAN Transmit";
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
                "arduinopio.blocks.common.CanTransmit", ...
                Title="CAN Transmit", ...
                Text="MCP2515 over SPI (Uno MOSI=11, MISO=12, SCK=13). OperatingMode: 0=normal, 1=loopback, 2=listen-only. Default CS=10; Seeed CAN-BUS Shield often uses CS=9.");
        end
    end
end
