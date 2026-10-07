classdef BoardAnalogInput < matlab.System & coder.ExternalDependency
    %BOARDANALOGINPUT - Read a uint16 ADC count from a named board.
    %   The output port is a scalar uint16. Pin checks use Board, so Mega can
    %   read analog channels 0-15 even when the model dialog is still on Uno.
    %   Host simulation returns SimValue. Generated code calls analogRead.
    %
    %   Syntax:
    %       obj = arduinopio.blocks.common.BoardAnalogInput
    %       obj = arduinopio.blocks.common.BoardAnalogInput(Name=value)
    %
    %   Inputs:
    %       Board - (1,1) string board id. Default "mega2560".
    %       Pin - (1,1) analog channel or GPIO. Default 0.
    %       SimValue - (1,1) uint16 host-simulation count. Default 0.
    %       SampleTime - (1,1) double. Default -1 (inherited).
    %
    %   Outputs:
    %       counts - scalar uint16.
    %
    %   Example:
    %       obj = arduinopio.blocks.common.BoardAnalogInput(Board="mega2560", Pin=8);
    %
    %   Other m-files required: arduinopio.validateBoardPin,
    %       arduinopio.updateDriverBuildInfo, arduinopio.iconWithPin
    %   Subfunctions: none
    %   MAT-files required: none
    %
    %   See also: BOARDPWM, VALIDATEBOARDPIN

    %   Author: Frey, Jed
    %   07-Oct-2026; Last revision: 07-Oct-2026

    properties (Nontunable)
        Board (1,1) string = "mega2560"
        Pin (1,1) {mustBeInteger, mustBeNonnegative} = 0
        SimValue (1,1) uint16 = 0
        SampleTime (1,1) double = -1
    end

    methods
        function obj = BoardAnalogInput(varargin)
            coder.allowpcode("plain");
            setProperties(obj, nargin, varargin{:});
        end
    end

    methods (Access = protected)
        function validatePropertiesImpl(obj)
            arduinopio.validateBoardPin(obj.Board, obj.Pin, "analog");
        end

        function counts = stepImpl(obj)
            counts = obj.SimValue;
            if coder.target("Rtw")
                coder.cinclude("arduinopio_arduino.h");
                counts = uint16(0);
                counts = coder.ceval("analogRead", uint8(obj.Pin));
            end
        end

        function num = getNumInputsImpl(~)
            num = 0;
        end

        function num = getNumOutputsImpl(~)
            num = 1;
        end

        function name = getOutputNamesImpl(~)
            name = "Counts";
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
            icon = arduinopio.iconWithPin("Analog In", obj.Pin);
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
            name = "Arduino PIO Board Analog Input";
        end

        function tf = isSupportedContext(context)
            tf = context.isCodeGenTarget("rtw");
        end

        function updateBuildInfo(buildInfo, context)
            arduinopio.updateDriverBuildInfo(buildInfo, context);
        end
    end
end
