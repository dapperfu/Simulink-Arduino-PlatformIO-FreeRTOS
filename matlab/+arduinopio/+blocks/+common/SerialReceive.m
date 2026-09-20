classdef (Sealed) SerialReceive < matlab.System & coder.ExternalDependency
    %SerialReceive Read bytes from Arduino hardware UART. Uno uses Serial0 on pins 0 and 1.
    %   The Common library block uses the Level-2 MATLAB S-function
    %   arduinopio_serial_receive instead of this System object.

    properties (Nontunable)
        Port (1,1) {mustBeInteger, mustBeNonnegative} = 0
        BaudRate (1,1) {mustBeInteger, mustBePositive} = 9600
        DataLength (1,1) {mustBeInteger, mustBePositive} = 1
        SampleTime (1,1) double = -1
    end

    methods
        function obj = SerialReceive(varargin)
            coder.allowpcode("plain");
            setProperties(obj, nargin, varargin{:});
        end
    end

    methods (Access = protected)
        function validatePropertiesImpl(obj)
            info = arduinopio.boards.getBoard();
            if obj.Port >= info.UartCount
                error("arduinopio:InvalidUart", ...
                    "%s has %d UART(s). Port must be in 0:%d.", ...
                    info.DisplayName, info.UartCount, info.UartCount-1);
            end
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
                count = coder.ceval("arduinopioUartRead", uint8(obj.Port), coder.wref(data), uint8(obj.DataLength));
                status = (count > 0);
            end
        end

        function num = getNumInputsImpl(~)
            num = 0;
        end

        function num = getNumOutputsImpl(~)
            num = 2;
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

        function icon = getIconImpl(~)
            icon = "Serial Receive";
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
            name = "Arduino PIO Serial Receive";
        end

        function tf = isSupportedContext(context)
            tf = context.isCodeGenTarget("rtw");
        end

        function updateBuildInfo(buildInfo, context)
            arduinopio.updateDriverBuildInfo(buildInfo, context, "arduinopio_uart.cpp");
        end
    end
end
