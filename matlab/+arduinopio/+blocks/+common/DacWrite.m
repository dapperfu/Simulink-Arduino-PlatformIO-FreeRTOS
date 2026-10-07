classdef DacWrite < matlab.System & coder.ExternalDependency
    %DACWRITE - Write a uint16 code to a board DAC pin.
    %   The input port is a scalar uint16. ResolutionBits is passed to
    %   arduinopioDacSetup. On ESP32 the driver calls dacWrite. On other
    %   non-AVR cores it calls analogWriteResolution and analogWrite. Host
    %   simulation does not write.
    %
    %   Syntax:
    %       obj = arduinopio.blocks.common.DacWrite
    %       obj = arduinopio.blocks.common.DacWrite(Name=value)
    %
    %   Inputs:
    %       Board - (1,1) string board id. Default "due".
    %       Pin - (1,1) DAC pin. Default 66 (Due DAC0).
    %       ResolutionBits - (1,1) integer 1 to 16. Default 12.
    %       SampleTime - (1,1) double. Default -1 (inherited).
    %       u (step) - scalar uint16 DAC code.
    %
    %   Outputs:
    %       obj - DacWrite System object. One input, no outputs.
    %
    %   Example:
    %       obj = arduinopio.blocks.common.DacWrite(Board="esp32Wroom", Pin=25, ResolutionBits=8);
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
        Board (1,1) string = "due"
        Pin (1,1) {mustBeInteger, mustBeNonnegative} = 66
        ResolutionBits (1,1) {mustBeInteger, mustBeInRange(ResolutionBits, 1, 16)} = 12
        SampleTime (1,1) double = -1
    end

    methods
        function obj = DacWrite(varargin)
            coder.allowpcode("plain");
            setProperties(obj, nargin, varargin{:});
        end
    end

    methods (Access = protected)
        function validatePropertiesImpl(obj)
            arduinopio.validateBoardPin(obj.Board, obj.Pin, "dac");
        end

        function setupImpl(obj)
            if coder.target("Rtw")
                coder.cinclude("arduinopio_dac.h");
                coder.ceval("arduinopioDacSetup", uint8(obj.Pin), uint8(obj.ResolutionBits));
            end
        end

        function stepImpl(obj, u)
            if coder.target("Rtw")
                coder.cinclude("arduinopio_dac.h");
                coder.ceval("arduinopioDacWrite", uint8(obj.Pin), uint16(u));
            end
        end

        function num = getNumInputsImpl(~)
            num = 1;
        end

        function num = getNumOutputsImpl(~)
            num = 0;
        end

        function name = getInputNamesImpl(~)
            name = "Code";
        end

        function sz = getInputSizeImpl(~)
            sz = [1, 1];
        end

        function dt = getInputDataTypeImpl(~)
            dt = "uint16";
        end

        function flag = isInputComplexImpl(~, ~)
            flag = false;
        end

        function flag = isInputFixedSizeImpl(~, ~)
            flag = true;
        end

        function icon = getIconImpl(obj)
            icon = arduinopio.iconWithPin("DAC", obj.Pin);
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
            name = "Arduino PIO DAC Write";
        end

        function tf = isSupportedContext(context)
            tf = context.isCodeGenTarget("rtw");
        end

        function updateBuildInfo(buildInfo, context)
            arduinopio.updateDriverBuildInfo(buildInfo, context, "arduinopio_dac.cpp");
        end
    end
end
