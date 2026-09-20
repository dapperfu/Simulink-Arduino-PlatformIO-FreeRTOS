classdef (Sealed) ExternalInterrupt < matlab.System & coder.ExternalDependency
    %ExternalInterrupt Detect an external pin interrupt. Output is true when an event is pending.

    properties (Nontunable)
        Pin (1,1) {mustBeInteger, mustBeNonnegative} = 2
        Mode (1,1) {mustBeInteger, mustBeMember(Mode, [0, 1, 2, 3])} = 3
        EnablePullup (1,1) logical = false
        SampleTime (1,1) double = -1
    end

    methods
        function obj = ExternalInterrupt(varargin)
            coder.allowpcode("plain");
            setProperties(obj, nargin, varargin{:});
        end
    end

    methods (Access = protected)
        function validatePropertiesImpl(obj)
            arduinopio.validatePin(obj.Pin, "interrupt");
        end

        function setupImpl(obj)
            if coder.target("Rtw")
                coder.cinclude("arduinopio_extint.h");
                coder.ceval("arduinopioExtIntSetup", uint8(obj.Pin), uint8(obj.Mode), uint8(obj.EnablePullup));
            end
        end

        function y = stepImpl(obj, simIrq)
            if coder.target("Rtw")
                y = (coder.ceval("arduinopioExtIntTake", uint8(obj.Pin)) ~= 0);
            else
                y = logical(simIrq);
            end
        end

        function num = getNumInputsImpl(~)
            num = 1;
        end

        function num = getNumOutputsImpl(~)
            num = 1;
        end

        function sz = getOutputSizeImpl(~)
            sz = [1, 1];
        end

        function dt = getOutputDataTypeImpl(~)
            dt = "logical";
        end

        function c = isOutputComplexImpl(~)
            c = false;
        end

        function f = isOutputFixedSizeImpl(~)
            f = true;
        end

        function icon = getIconImpl(~)
            icon = "External Interrupt";
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
            name = "Arduino PIO External Interrupt";
        end

        function tf = isSupportedContext(context)
            tf = context.isCodeGenTarget("rtw");
        end

        function updateBuildInfo(buildInfo, context)
            arduinopio.updateDriverBuildInfo(buildInfo, context, "arduinopio_extint.cpp");
        end
    end

    methods (Static, Access = protected)
        function header = getHeaderImpl()
            header = matlab.system.display.Header( ...
                "arduinopio.blocks.common.ExternalInterrupt", ...
                Title="External Interrupt", ...
                Text="Uno pins 2 (INT0) and 3 (INT1). Mode: 0=LOW, 1=CHANGE, 2=FALLING, 3=RISING. SimIRQ is used only in simulation.");
        end
    end
end
