classdef UartReceive < matlab.System & coder.ExternalDependency
    %UARTRECEIVE - Read a fixed uint8 frame from a hardware UART port.
    %   Outputs are uint8 data of length DataLength and a logical status that
    %   is true when at least one byte was read. Host simulation returns zeros
    %   and false. Generated code calls arduinopioUartSetup and arduinopioUartRead.
    %
    %   Syntax:
    %       obj = arduinopio.blocks.common.UartReceive
    %       obj = arduinopio.blocks.common.UartReceive(Name=value)
    %
    %   Inputs:
    %       Board - (1,1) string board id. Default "mega2560".
    %       Port - (1,1) UART index. Default 1.
    %       BaudRate - (1,1) positive integer. Default 115200.
    %       DataLength - (1,1) bytes per step, 1 to 64. Default 1.
    %       SampleTime - (1,1) double. Default -1 (inherited).
    %
    %   Outputs:
    %       data - uint8 column of length DataLength.
    %       status - logical scalar.
    %
    %   Example:
    %       obj = arduinopio.blocks.common.UartReceive(Board="due", Port=2);
    %
    %   Other m-files required: arduinopio.validateBoardPin,
    %       arduinopio.updateDriverBuildInfo, arduinopio.iconWithPin
    %   Subfunctions: none
    %   MAT-files required: none
    %
    %   See also: UARTTRANSMIT, VALIDATEBOARDPIN

    %   Author: Frey, Jed
    %   07-Oct-2026; Last revision: 07-Oct-2026

    properties (Nontunable)
        Board (1,1) string = "mega2560"
        Port (1,1) {mustBeInteger, mustBeNonnegative} = 1
        BaudRate (1,1) {mustBeInteger, mustBePositive} = 115200
        DataLength (1,1) {mustBeInteger, mustBeInRange(DataLength, 1, 64)} = 1
        SampleTime (1,1) double = -1
    end

    methods
        function obj = UartReceive(varargin)
            coder.allowpcode("plain");
            setProperties(obj, nargin, varargin{:});
        end
    end

    methods (Access = protected)
        function validatePropertiesImpl(obj)
            arduinopio.validateBoardPin(obj.Board, obj.Port, "uart");
        end

        function setupImpl(obj)
            if coder.target("Rtw")
                coder.cinclude("arduinopio_uart.h");
                coder.ceval("arduinopioUartSetup", uint8(obj.Port), uint32(obj.BaudRate));
            end
        end

        function [data, status] = stepImpl(obj)
            data = zeros(obj.DataLength, 1, "uint8");
            status = false;
            if coder.target("Rtw")
                count = uint8(0);
                coder.cinclude("arduinopio_uart.h");
                count = coder.ceval("arduinopioUartRead", uint8(obj.Port), coder.wref(data), uint8(obj.DataLength));
                status = count > 0;
            end
        end

        function num = getNumInputsImpl(~)
            num = 0;
        end

        function num = getNumOutputsImpl(~)
            num = 2;
        end

        function names = getOutputNamesImpl(~)
            names = ["Data", "Status"];
        end

        function [sz1, sz2] = getOutputSizeImpl(obj)
            sz1 = [obj.DataLength, 1];
            sz2 = [1, 1];
        end

        function [dt1, dt2] = getOutputDataTypeImpl(~)
            dt1 = "uint8";
            dt2 = "logical";
        end

        function [c1, c2] = isOutputComplexImpl(~)
            c1 = false;
            c2 = false;
        end

        function [f1, f2] = isOutputFixedSizeImpl(~)
            f1 = true;
            f2 = true;
        end

        function icon = getIconImpl(obj)
            icon = arduinopio.iconWithPin("UART RX", obj.Port, Label="Port");
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
            name = "Arduino PIO UART Receive";
        end

        function tf = isSupportedContext(context)
            tf = context.isCodeGenTarget("rtw");
        end

        function updateBuildInfo(buildInfo, context)
            arduinopio.updateDriverBuildInfo(buildInfo, context, "arduinopio_uart.cpp");
        end
    end
end
