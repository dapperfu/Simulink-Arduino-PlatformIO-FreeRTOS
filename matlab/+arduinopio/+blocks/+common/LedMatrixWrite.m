classdef LedMatrixWrite < matlab.System & coder.ExternalDependency
    %LEDMATRIXWRITE - Write 12 column bytes to the Uno R4 WiFi 12x8 LED matrix.
    %   The input port is uint8(12,1). Bit 0 of each byte is row 0. Generated
    %   code calls Arduino_LED_Matrix loadFrame. This class always records the
    %   Arduino_LED_Matrix lib_dep because the block is only placed on Uno R4.
    %
    %   Syntax:
    %       obj = arduinopio.blocks.common.LedMatrixWrite
    %       obj = arduinopio.blocks.common.LedMatrixWrite(Name=value)
    %
    %   Inputs:
    %       SampleTime - (1,1) double. Default -1.
    %       u (step) - uint8 column of length 12.
    %
    %   Outputs:
    %       obj - LedMatrixWrite System object.
    %
    %   Example:
    %       obj = arduinopio.blocks.common.LedMatrixWrite(SampleTime=0.1);
    %
    %   Other m-files required: arduinopio.updateDriverBuildInfo, arduinopio.addLibDep
    %   Subfunctions: none
    %   MAT-files required: none
    %
    %   See also: ADDLIBDEP

    %   Author: Frey, Jed
    %   07-Oct-2026; Last revision: 07-Oct-2026

    properties (Nontunable)
        SampleTime (1,1) double = -1
    end

    methods
        function obj = LedMatrixWrite(varargin)
            coder.allowpcode("plain");
            setProperties(obj, nargin, varargin{:});
        end
    end

    methods (Access = protected)
        function setupImpl(~)
            if coder.target("Rtw")
                coder.cinclude("arduinopio_matrix.h");
                coder.ceval("arduinopioMatrixSetup");
            end
        end

        function stepImpl(~, u)
            if coder.target("Rtw")
                columns = uint8(u(:));
                coder.cinclude("arduinopio_matrix.h");
                coder.ceval("arduinopioMatrixWrite", coder.rref(columns), uint8(numel(columns)));
            end
        end

        function num = getNumInputsImpl(~)
            num = 1;
        end

        function num = getNumOutputsImpl(~)
            num = 0;
        end

        function name = getInputNamesImpl(~)
            name = "Columns";
        end

        function sz = getInputSizeImpl(~)
            sz = [12, 1];
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

        function icon = getIconImpl(~)
            icon = ["LED Matrix"; "12 x 8"];
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
            name = "Arduino PIO LED Matrix";
        end

        function tf = isSupportedContext(context)
            tf = context.isCodeGenTarget("rtw");
        end

        function updateBuildInfo(buildInfo, context)
            arduinopio.updateDriverBuildInfo(buildInfo, context, "arduinopio_matrix.cpp", "LED_MATRIX");
        end
    end
end
