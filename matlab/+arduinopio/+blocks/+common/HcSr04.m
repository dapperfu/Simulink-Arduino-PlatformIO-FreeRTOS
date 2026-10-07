classdef (Sealed) HcSr04 < matlab.System & coder.ExternalDependency
    %HCSR04 - Measure distance from an HC-SR04 ultrasonic sensor in centimeters.
    %   TrigPin and EchoPin are digital GPIO. Default SampleTime is 0.01 s (10 ms).
    %   Host simulation returns SimValue. Generated code pulses Trig and times Echo
    %   via arduinopioHcSr04ReadCm. Timeout scales from MaxDistanceCm.
    %
    %   Syntax:
    %       obj = arduinopio.blocks.common.HcSr04
    %       obj = arduinopio.blocks.common.HcSr04(Name=value)
    %
    %   Inputs:
    %       TrigPin - (1,1) digital trigger pin. Default 9.
    %       EchoPin - (1,1) digital echo pin. Default 8.
    %       MaxDistanceCm - (1,1) double timeout range in cm. Default 400.
    %       SimValue - (1,1) double host-simulation distance in cm. Default 0.
    %       SampleTime - (1,1) double. Default 0.01 (10 ms).
    %
    %   Outputs:
    %       distanceCm - scalar double distance in centimeters (0 on timeout).
    %
    %   Example:
    %       obj = arduinopio.blocks.common.HcSr04(TrigPin=9, EchoPin=8);
    %
    %   Other m-files required: arduinopio.validatePin,
    %       arduinopio.updateDriverBuildInfo, arduinopio.iconWithPin
    %   Subfunctions: none
    %   MAT-files required: none
    %
    %   See also: DIGITALINPUT, VALIDATEPIN

    %   Author: Frey, Jed
    %   07-Oct-2026; Last revision: 07-Oct-2026

    properties (Nontunable)
        TrigPin (1,1) {mustBeInteger, mustBeNonnegative} = 9
        EchoPin (1,1) {mustBeInteger, mustBeNonnegative} = 8
        MaxDistanceCm (1,1) double {mustBePositive} = 400
        SimValue (1,1) double = 0
        SampleTime (1,1) double = 0.01
    end

    methods
        function obj = HcSr04(varargin)
            coder.allowpcode("plain");
            setProperties(obj, nargin, varargin{:});
        end
    end

    methods (Access = protected)
        function validatePropertiesImpl(obj)
            arduinopio.validatePin(obj.TrigPin, "digital");
            arduinopio.validatePin(obj.EchoPin, "digital");
            if obj.TrigPin == obj.EchoPin
                error("arduinopio:InvalidPin", ...
                    "HC-SR04 TrigPin and EchoPin must be different.");
            end
            if obj.SampleTime ~= -1 && obj.SampleTime <= 0
                error("arduinopio:InvalidSampleTime", ...
                    "SampleTime must be -1 (inherited) or a positive period in seconds.");
            end
        end

        function setupImpl(obj)
            if coder.target("Rtw")
                coder.cinclude("arduinopio_hcsr04.h");
                coder.ceval("arduinopioHcSr04Setup", uint8(obj.TrigPin), uint8(obj.EchoPin));
            end
        end

        function distanceCm = stepImpl(obj)
            distanceCm = obj.SimValue;
            if coder.target("Rtw")
                coder.cinclude("arduinopio_hcsr04.h");
                timeoutUs = uint32(ceil(obj.MaxDistanceCm * 58));
                rawCm = single(0);
                rawCm = coder.ceval("arduinopioHcSr04ReadCm", ...
                    uint8(obj.TrigPin), uint8(obj.EchoPin), timeoutUs);
                distanceCm = double(rawCm);
            end
        end

        function num = getNumInputsImpl(~)
            num = 0;
        end

        function num = getNumOutputsImpl(~)
            num = 1;
        end

        function name = getOutputNamesImpl(~)
            name = "DistanceCm";
        end

        function sz = getOutputSizeImpl(~)
            sz = [1, 1];
        end

        function dt = getOutputDataTypeImpl(~)
            dt = "double";
        end

        function flag = isOutputComplexImpl(~)
            flag = false;
        end

        function flag = isOutputFixedSizeImpl(~)
            flag = true;
        end

        function icon = getIconImpl(obj)
            icon = arduinopio.iconWithPin("HC-SR04", [obj.TrigPin, obj.EchoPin]);
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
            name = "Arduino PIO HC-SR04";
        end

        function tf = isSupportedContext(context)
            tf = context.isCodeGenTarget("rtw");
        end

        function updateBuildInfo(buildInfo, context)
            arduinopio.updateDriverBuildInfo(buildInfo, context, "arduinopio_hcsr04.cpp");
        end
    end
end
