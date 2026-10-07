classdef NativeCanReceive < matlab.System & coder.ExternalDependency
    %NATIVECANRECEIVE - Poll one native CAN controller for an 8-byte frame.
    %   Outputs are uint32 Id, uint8 Data(8,1), uint8 Length, and logical Status.
    %   Status is false on the host and when no frame is waiting. Due uses
    %   due_can. The Uno R4 subclass links Arduino_CAN.
    %
    %   Syntax:
    %       obj = arduinopio.blocks.common.NativeCanReceive
    %       obj = arduinopio.blocks.common.NativeCanReceive(Name=value)
    %
    %   Inputs:
    %       Board, Controller, BaudRateKbps, and SampleTime. See NativeCanTransmit.
    %
    %   Outputs:
    %       identifier - scalar uint32.
    %       data - uint8 column of length 8.
    %       length - scalar uint8.
    %       status - logical scalar.
    %
    %   Example:
    %       obj = arduinopio.blocks.common.NativeCanReceive(Board="due", Controller=0);
    %
    %   Other m-files required: arduinopio.validateBoardPin,
    %       arduinopio.updateDriverBuildInfo
    %   Subfunctions: none
    %   MAT-files required: none
    %
    %   See also: NATIVECANTRANSMIT

    %   Author: Frey, Jed
    %   07-Oct-2026; Last revision: 07-Oct-2026

    properties (Nontunable)
        Board (1,1) string = "due"
        Controller (1,1) {mustBeInteger, mustBeNonnegative} = 0
        BaudRateKbps (1,1) {mustBeMember(BaudRateKbps, [125, 250, 500, 1000])} = 500
        SampleTime (1,1) double = -1
    end

    methods
        function obj = NativeCanReceive(varargin)
            coder.allowpcode("plain");
            setProperties(obj, nargin, varargin{:});
        end
    end

    methods (Access = protected)
        function validatePropertiesImpl(obj)
            arduinopio.validateBoardPin(obj.Board, obj.Controller, "can");
        end

        function setupImpl(obj)
            if coder.target("Rtw")
                coder.cinclude("arduinopio_native_can.h");
                coder.ceval("arduinopioNativeCanSetup", uint8(obj.Controller), uint16(obj.BaudRateKbps));
            end
        end

        function [identifier, data, length, status] = stepImpl(obj)
            identifier = uint32(0);
            data = zeros(8, 1, "uint8");
            length = uint8(0);
            status = false;
            if coder.target("Rtw")
                extended = uint8(0);
                remote = uint8(0);
                gotFrame = uint8(0);
                coder.cinclude("arduinopio_native_can.h");
                gotFrame = coder.ceval("arduinopioNativeCanReceive", uint8(obj.Controller), ...
                    coder.wref(identifier), coder.wref(extended), coder.wref(remote), ...
                    coder.wref(data), coder.wref(length));
                status = gotFrame ~= 0;
            end
        end

        function num = getNumInputsImpl(~)
            num = 0;
        end

        function num = getNumOutputsImpl(~)
            num = 4;
        end

        function names = getOutputNamesImpl(~)
            names = ["Id", "Data", "Length", "Status"];
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
            icon = ["Onboard CAN RX"; "Controller " + string(obj.Controller)];
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
            name = "Arduino PIO Native CAN Receive";
        end

        function tf = isSupportedContext(context)
            tf = context.isCodeGenTarget("rtw");
        end

        function updateBuildInfo(buildInfo, context)
            arduinopio.updateDriverBuildInfo(buildInfo, context, "arduinopio_native_can.cpp");
        end
    end
end
