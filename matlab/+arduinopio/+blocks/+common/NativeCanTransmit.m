classdef NativeCanTransmit < matlab.System & coder.ExternalDependency
    %NATIVECANTRANSMIT - Send an 8-byte uint8 CAN frame on a native controller.
    %   Due uses due_can (Can0/Can1). Uno R4 uses Arduino_CAN; the Uno R4
    %   subclass adds that library dependency. The input port is uint8(8,1).
    %   Host simulation does not transmit.
    %
    %   Syntax:
    %       obj = arduinopio.blocks.common.NativeCanTransmit
    %       obj = arduinopio.blocks.common.NativeCanTransmit(Name=value)
    %
    %   Inputs:
    %       Board - (1,1) string. Default "due".
    %       Controller - (1,1) controller index. Default 0.
    %       BaudRateKbps - member of [125 250 500 1000]. Default 500.
    %       MessageId - (1,1) nonnegative integer. Default 256.
    %       ExtendedFrame - (1,1) logical. Default false.
    %       RemoteFrame - (1,1) logical. Default false.
    %       SampleTime - (1,1) double. Default -1.
    %       u (step) - uint8 column of length 8.
    %
    %   Outputs:
    %       obj - NativeCanTransmit System object.
    %
    %   Example:
    %       obj = arduinopio.blocks.common.NativeCanTransmit(Board="due", Controller=1);
    %
    %   Other m-files required: arduinopio.validateBoardPin,
    %       arduinopio.validateCanIdentifier, arduinopio.updateDriverBuildInfo
    %   Subfunctions: none
    %   MAT-files required: none
    %
    %   See also: NATIVECANRECEIVE, VALIDATECANIDENTIFIER

    %   Author: Frey, Jed
    %   07-Oct-2026; Last revision: 07-Oct-2026

    properties (Nontunable)
        Board (1,1) string = "due"
        Controller (1,1) {mustBeInteger, mustBeNonnegative} = 0
        BaudRateKbps (1,1) {mustBeMember(BaudRateKbps, [125, 250, 500, 1000])} = 500
        MessageId (1,1) {mustBeInteger, mustBeNonnegative} = 256
        ExtendedFrame (1,1) logical = false
        RemoteFrame (1,1) logical = false
        SampleTime (1,1) double = -1
    end

    methods
        function obj = NativeCanTransmit(varargin)
            coder.allowpcode("plain");
            setProperties(obj, nargin, varargin{:});
        end
    end

    methods (Access = protected)
        function validatePropertiesImpl(obj)
            arduinopio.validateBoardPin(obj.Board, obj.Controller, "can");
            arduinopio.validateCanIdentifier(obj.MessageId, obj.ExtendedFrame, "MessageId");
        end

        function setupImpl(obj)
            if coder.target("Rtw")
                coder.cinclude("arduinopio_native_can.h");
                coder.ceval("arduinopioNativeCanSetup", uint8(obj.Controller), uint16(obj.BaudRateKbps));
            end
        end

        function stepImpl(obj, u)
            if coder.target("Rtw")
                data = uint8(u(:));
                coder.cinclude("arduinopio_native_can.h");
                coder.ceval("arduinopioNativeCanSend", uint8(obj.Controller), uint32(obj.MessageId), ...
                    uint8(obj.ExtendedFrame), uint8(obj.RemoteFrame), coder.rref(data), uint8(numel(data)));
            end
        end

        function num = getNumInputsImpl(~)
            num = 1;
        end

        function num = getNumOutputsImpl(~)
            num = 0;
        end

        function name = getInputNamesImpl(~)
            name = "Data";
        end

        function sz = getInputSizeImpl(~)
            sz = [8, 1];
        end

        function dt = getInputDataTypeImpl(~)
            dt = "uint8";
        end

        function flag = isInputComplexImpl(~, ~)
            flag = false;
        end

        function flag = isInputFixedSizeImpl(~, ~)
            flag = true;
        end

        function icon = getIconImpl(obj)
            icon = ["Onboard CAN TX"; "Controller " + string(obj.Controller)];
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
            name = "Arduino PIO Native CAN Transmit";
        end

        function tf = isSupportedContext(context)
            tf = context.isCodeGenTarget("rtw");
        end

        function updateBuildInfo(buildInfo, context)
            arduinopio.updateDriverBuildInfo(buildInfo, context, "arduinopio_native_can.cpp");
        end
    end
end
