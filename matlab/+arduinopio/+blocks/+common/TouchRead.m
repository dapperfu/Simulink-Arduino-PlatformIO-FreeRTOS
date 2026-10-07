classdef TouchRead < matlab.System & coder.ExternalDependency
    %TOUCHREAD - Read an ESP32 touch pad as a scalar uint16.
    %   Pin is a touch-capable GPIO. Host simulation returns SimValue. Generated
    %   code calls touchRead. Other architectures return 0 from the driver.
    %
    %   Syntax:
    %       obj = arduinopio.blocks.common.TouchRead
    %       obj = arduinopio.blocks.common.TouchRead(Name=value)
    %
    %   Inputs:
    %       Board - (1,1) string. Default "esp32Wroom".
    %       Pin - (1,1) touch GPIO. Default 4.
    %       SimValue - (1,1) uint16 host value. Default 0.
    %       SampleTime - (1,1) double. Default -1.
    %
    %   Outputs:
    %       value - scalar uint16.
    %
    %   Example:
    %       obj = arduinopio.blocks.common.TouchRead(Pin=4);
    %
    %   Other m-files required: arduinopio.validateBoardPin,
    %       arduinopio.updateDriverBuildInfo, arduinopio.iconWithPin
    %   Subfunctions: none
    %   MAT-files required: none
    %
    %   See also: VALIDATEBOARDPIN

    %   Author: Frey, Jed
    %   07-Oct-2026; Last revision: 07-Oct-2026

    properties (Nontunable)
        Board (1,1) string = "esp32Wroom"
        Pin (1,1) {mustBeInteger, mustBeNonnegative} = 4
        SimValue (1,1) uint16 = 0
        SampleTime (1,1) double = -1
    end

    methods
        function obj = TouchRead(varargin)
            coder.allowpcode("plain");
            setProperties(obj, nargin, varargin{:});
        end
    end

    methods (Access = protected)
        function validatePropertiesImpl(obj)
            arduinopio.validateBoardPin(obj.Board, obj.Pin, "touch");
        end

        function setupImpl(obj)
            if coder.target("Rtw")
                coder.cinclude("arduinopio_touch.h");
                coder.ceval("arduinopioTouchSetup", uint8(obj.Pin));
            end
        end

        function value = stepImpl(obj)
            value = obj.SimValue;
            if coder.target("Rtw")
                coder.cinclude("arduinopio_touch.h");
                value = uint16(0);
                value = coder.ceval("arduinopioTouchRead", uint8(obj.Pin));
            end
        end

        function num = getNumInputsImpl(~)
            num = 0;
        end

        function num = getNumOutputsImpl(~)
            num = 1;
        end

        function name = getOutputNamesImpl(~)
            name = "Value";
        end

        function sz = getOutputSizeImpl(~)
            sz = [1, 1];
        end

        function dt = getOutputDataTypeImpl(~)
            dt = "uint16";
        end

        function flag = isOutputComplexImpl(~)
            flag = false;
        end

        function flag = isOutputFixedSizeImpl(~)
            flag = true;
        end

        function icon = getIconImpl(obj)
            icon = arduinopio.iconWithPin("Touch", obj.Pin);
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
            name = "Arduino PIO Touch Read";
        end

        function tf = isSupportedContext(context)
            tf = context.isCodeGenTarget("rtw");
        end

        function updateBuildInfo(buildInfo, context)
            arduinopio.updateDriverBuildInfo(buildInfo, context, "arduinopio_touch.cpp");
        end
    end
end
