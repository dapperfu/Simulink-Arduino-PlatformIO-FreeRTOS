classdef UartTransmit < matlab.System & coder.ExternalDependency
    %UARTTRANSMIT - Send a fixed uint8 frame on a hardware UART port.
    %   MATLAB System object and coder.ExternalDependency. The input port is
    %   uint8 and DataLength-by-1. setupImpl calls arduinopioUartSetup. stepImpl
    %   calls arduinopioUartWrite. Host simulation does not write. Not sealed so
    %   a board package can add a PlatformIO library in updateBuildInfo.
    %
    %   Syntax:
    %       obj = arduinopio.blocks.common.UartTransmit
    %       obj = arduinopio.blocks.common.UartTransmit(Name=value)
    %
    %   Inputs:
    %       Board - (1,1) string board id. Default "mega2560".
    %       Port - (1,1) UART index. Default 1.
    %       BaudRate - (1,1) positive integer. Default 115200.
    %       DataLength - (1,1) bytes per step, 1 to 64. Default 1.
    %       SampleTime - (1,1) double. Default -1 (inherited).
    %       u (step) - uint8 column of length DataLength.
    %
    %   Outputs:
    %       obj - UartTransmit System object. One input, no outputs.
    %
    %   Example:
    %       obj = arduinopio.blocks.common.UartTransmit(Board="due", Port=1);
    %
    %   Other m-files required: arduinopio.validateBoardPin,
    %       arduinopio.updateDriverBuildInfo, arduinopio.iconWithPin
    %   Subfunctions: none
    %   MAT-files required: none
    %
    %   See also: UARTRECEIVE, VALIDATEBOARDPIN

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
        function obj = UartTransmit(varargin)
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

        function stepImpl(obj, u)
            if coder.target("Rtw")
                data = uint8(u(:));
                coder.cinclude("arduinopio_uart.h");
                coder.ceval("arduinopioUartWrite", uint8(obj.Port), coder.rref(data), uint8(numel(data)));
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

        function sz = getInputSizeImpl(obj)
            sz = [obj.DataLength, 1];
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
            icon = arduinopio.iconWithPin("UART TX", obj.Port, Label="Port");
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
            name = "Arduino PIO UART Transmit";
        end

        function tf = isSupportedContext(context)
            tf = context.isCodeGenTarget("rtw");
        end

        function updateBuildInfo(buildInfo, context)
            arduinopio.updateDriverBuildInfo(buildInfo, context, "arduinopio_uart.cpp");
        end
    end
end
