classdef BoardPwm < matlab.System & coder.ExternalDependency
    %BOARDPWM - analogWrite a uint8 duty cycle on a PWM pin of a named board.
    %   The input port is a scalar uint8, 0-255. Pin checks use Board rather
    %   than the model PlatformIO board, so a Mega or Nano 33 BLE library block
    %   accepts that board's PWM pins. Generated code calls pinMode and
    %   analogWrite through arduinopio_arduino.h.
    %
    %   Syntax:
    %       obj = arduinopio.blocks.common.BoardPwm
    %       obj = arduinopio.blocks.common.BoardPwm(Name=value)
    %
    %   Inputs:
    %       Board - (1,1) string board id. Default "mega2560".
    %       Pin - (1,1) PWM pin. Default 2.
    %       SampleTime - (1,1) double. Default -1 (inherited).
    %       u (step) - scalar uint8 duty.
    %
    %   Outputs:
    %       obj - BoardPwm System object. One input, no outputs.
    %
    %   Example:
    %       obj = arduinopio.blocks.common.BoardPwm(Board="nano33Ble", Pin=3);
    %
    %   Other m-files required: arduinopio.validateBoardPin,
    %       arduinopio.updateDriverBuildInfo, arduinopio.iconWithPin
    %   Subfunctions: none
    %   MAT-files required: none
    %
    %   See also: BOARDANALOGINPUT, VALIDATEBOARDPIN

    %   Author: Frey, Jed
    %   07-Oct-2026; Last revision: 07-Oct-2026

    properties (Nontunable)
        Board (1,1) string = "mega2560"
        Pin (1,1) {mustBeInteger, mustBeNonnegative} = 2
        SampleTime (1,1) double = -1
    end

    methods
        function obj = BoardPwm(varargin)
            coder.allowpcode("plain");
            setProperties(obj, nargin, varargin{:});
        end
    end

    methods (Access = protected)
        function validatePropertiesImpl(obj)
            arduinopio.validateBoardPin(obj.Board, obj.Pin, "pwm");
        end

        function setupImpl(obj)
            if coder.target("Rtw")
                coder.cinclude("arduinopio_arduino.h");
                coder.ceval("pinMode", uint8(obj.Pin), coder.opaque("uint8_t", "OUTPUT"));
                coder.ceval("analogWrite", uint8(obj.Pin), int32(0));
            end
        end

        function stepImpl(obj, u)
            if coder.target("Rtw")
                coder.cinclude("arduinopio_arduino.h");
                coder.ceval("analogWrite", uint8(obj.Pin), int32(u));
            end
        end

        function num = getNumInputsImpl(~)
            num = 1;
        end

        function num = getNumOutputsImpl(~)
            num = 0;
        end

        function name = getInputNamesImpl(~)
            name = "Duty";
        end

        function sz = getInputSizeImpl(~)
            sz = [1, 1];
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
            icon = arduinopio.iconWithPin("PWM", obj.Pin);
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
            name = "Arduino PIO Board PWM";
        end

        function tf = isSupportedContext(context)
            tf = context.isCodeGenTarget("rtw");
        end

        function updateBuildInfo(buildInfo, context)
            arduinopio.updateDriverBuildInfo(buildInfo, context);
        end
    end
end
