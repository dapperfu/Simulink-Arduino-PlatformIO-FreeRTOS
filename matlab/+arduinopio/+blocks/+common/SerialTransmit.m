classdef (Sealed) SerialTransmit < matlab.System & coder.ExternalDependency
    %SerialTransmit Send bytes on Arduino hardware UART. Uno uses Serial0 on pins 0 and 1.
    %   The Common library block uses the Level-2 MATLAB S-function
    %   arduinopio_serial_transmit instead of this System object.

    properties (Nontunable)
        Port (1,1) {mustBeInteger, mustBeNonnegative} = 0
        BaudRate (1,1) {mustBeInteger, mustBePositive} = 9600
        SampleTime (1,1) double = -1
    end

    methods
        function obj = SerialTransmit(varargin)
            coder.allowpcode("plain");
            setProperties(obj, nargin, varargin{:});
        end
    end

    methods (Access = protected)
        function validatePropertiesImpl(obj)
            arduinopio.validateUartPort(obj.Port);
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
                coder.ceval("arduinopioUartWrite", uint8(obj.Port), coder.rref(data), uint8(numel(data)));
            end
        end

        function num = getNumInputsImpl(~)
            num = 1;
        end

        function num = getNumOutputsImpl(~)
            num = 0;
        end

        function icon = getIconImpl(~)
            icon = "Serial Transmit";
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
            name = "Arduino PIO Serial Transmit";
        end

        function tf = isSupportedContext(context)
            tf = context.isCodeGenTarget("rtw");
        end

        function updateBuildInfo(buildInfo, context)
            arduinopio.updateDriverBuildInfo(buildInfo, context, "arduinopio_uart.cpp");
        end
    end
end
