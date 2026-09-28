classdef (Sealed) AnalogInputAvr < matlab.System & coder.ExternalDependency
    %ANALOGINPUTAVR - Read the AVR ADC with explicit reference and prescaler.
    %   Sealed matlab.System plus coder.ExternalDependency for Advanced AVR ADC.
    %   Nontunable Pin defaults to 0; ReferenceSelect defaults to 1 (member of
    %   {0,1,3}: AREF, AVcc, internal 1.1 V per getHeaderImpl); PrescalerSelect
    %   defaults to 7 (member of 1:7 mapping to /2../128); SampleTime defaults
    %   to -1 (inherited). validatePropertiesImpl validates kind "analog".
    %   On RTW, setupImpl includes arduinopio_adc_avr.h and calls
    %   arduinopioAdcAvrSetup(Pin, ReferenceSelect, PrescalerSelect). stepImpl
    %   returns uint16; on RTW from arduinopioAdcAvrRead, on host 0.
    %   updateBuildInfo adds arduinopio_adc_avr.cpp.
    %
    %   Syntax:
    %       obj = arduinopio.blocks.avr.AnalogInputAvr
    %       obj = arduinopio.blocks.avr.AnalogInputAvr(Name=value)
    %
    %   Inputs:
    %       Pin             - (1,1) nonnegative integer ADC channel. Default: 0.
    %       ReferenceSelect - (1,1) integer in {0,1,3}. Default: 1 (AVcc).
    %       PrescalerSelect - (1,1) integer in 1:7. Default: 7.
    %       SampleTime      - (1,1) double. Default: -1 (inherited).
    %
    %   Outputs:
    %       obj - AnalogInputAvr System object.
    %       y   - stepImpl output: ADC reading as uint16 (0 on host).
    %
    %   Example:
    %       obj = arduinopio.blocks.avr.AnalogInputAvr(Pin=0, ReferenceSelect=1);
    %
    %   Other m-files required: arduinopio.validatePin, arduinopio.iconWithPin,
    %       arduinopio.updateDriverBuildInfo
    %   Subfunctions: none
    %   MAT-files required: none
    %
    %   See also: PWMAVR, HARDWAREINTERRUPTAVR

    %   Author: Frey, Jed
    %   28-Sep-2026; Last revision: 28-Sep-2026

    properties (Nontunable)
        Pin (1,1) {mustBeInteger, mustBeNonnegative} = 0
        ReferenceSelect (1,1) {mustBeInteger, mustBeMember(ReferenceSelect, [0, 1, 3])} = 1
        PrescalerSelect (1,1) {mustBeInteger, mustBeMember(PrescalerSelect, 1:7)} = 7
        SampleTime (1,1) double = -1
    end

    methods
        function obj = AnalogInputAvr(varargin)
        %ANALOGINPUTAVR - Construct an AnalogInputAvr System object.
        %   Calls coder.allowpcode("plain") and setProperties for nontunable
        %   pin, reference, prescaler, and sample-time properties.
        %
        %   Syntax:
        %       obj = AnalogInputAvr()
        %       obj = AnalogInputAvr(Name=value)
        %
        %   Inputs:
        %       varargin - Optional name-value pairs for nontunable properties.
        %
        %   Outputs:
        %       obj - Constructed AnalogInputAvr instance.
        %
        %   Example:
        %       obj = arduinopio.blocks.avr.AnalogInputAvr(PrescalerSelect=7);
        %
        %   See also: SETUPIMPL, STEPIMPL

            coder.allowpcode("plain");
            setProperties(obj, nargin, varargin{:});
        end
    end

    methods (Access = protected)
        function validatePropertiesImpl(obj)
        %VALIDATEPROPERTIESIMPL - Validate the ADC pin as analog input.
        %   Calls arduinopio.validatePin(obj.Pin, "analog").
        %
        %   Syntax:
        %       validatePropertiesImpl(obj)
        %
        %   Inputs:
        %       obj - AnalogInputAvr System object.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       % Invoked by the System object framework during setup.
        %
        %   See also: VALIDATEPIN

            arduinopio.validatePin(obj.Pin, "analog");
        end

        function setupImpl(obj)
        %SETUPIMPL - Configure AVR ADC reference and prescaler on RTW.
        %   When coder.target is "Rtw", includes arduinopio_adc_avr.h and calls
        %   arduinopioAdcAvrSetup(Pin, ReferenceSelect, PrescalerSelect).
        %   No host setup.
        %
        %   Syntax:
        %       setupImpl(obj)
        %
        %   Inputs:
        %       obj - AnalogInputAvr System object.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       % Invoked once before stepImpl during simulation or codegen.
        %
        %   See also: STEPIMPL, ARDUINOPIOADCAVRSETUP

            if coder.target("Rtw")
                coder.cinclude("arduinopio_adc_avr.h");
                coder.ceval("arduinopioAdcAvrSetup", uint8(obj.Pin), uint8(obj.ReferenceSelect), ...
                    uint8(obj.PrescalerSelect));
            end
        end

        function y = stepImpl(obj)
        %STEPIMPL - Read one AVR ADC conversion result.
        %   Initializes y to uint16(0). On RTW assigns y from
        %   arduinopioAdcAvrRead(Pin). Host returns 0.
        %
        %   Syntax:
        %       y = stepImpl(obj)
        %
        %   Inputs:
        %       obj - AnalogInputAvr System object.
        %
        %   Outputs:
        %       y - ADC reading as uint16; 0 on host simulation.
        %
        %   Example:
        %       % Driven each sample by the Simulink System block.
        %
        %   See also: SETUPIMPL, ARDUINOPIOADCAVRREAD

            y = uint16(0);
            if coder.target("Rtw")
                y = coder.ceval("arduinopioAdcAvrRead", uint8(obj.Pin));
            end
        end

        function num = getNumInputsImpl(~)
        %GETNUMINPUTSIMPL - Report zero input ports for ADC read.
        %   Returns a fixed input count of 0.
        %
        %   Syntax:
        %       num = getNumInputsImpl(obj)
        %
        %   Inputs:
        %       ~ - Unused System object.
        %
        %   Outputs:
        %       num - Number of inputs (0).
        %
        %   Example:
        %       % Queried by the System object framework.
        %
        %   See also: GETNUMOUTPUTSIMPL

            num = 0;
        end

        function num = getNumOutputsImpl(~)
        %GETNUMOUTPUTSIMPL - Report one output port for the ADC value.
        %   Returns a fixed output count of 1.
        %
        %   Syntax:
        %       num = getNumOutputsImpl(obj)
        %
        %   Inputs:
        %       ~ - Unused System object.
        %
        %   Outputs:
        %       num - Number of outputs (1).
        %
        %   Example:
        %       % Queried by the System object framework.
        %
        %   See also: GETNUMINPUTSIMPL

            num = 1;
        end

        function sz = getOutputSizeImpl(~)
        %GETOUTPUTSIZEIMPL - ADC output is 1-by-1.
        %   Returns [1, 1].
        %
        %   Syntax:
        %       sz = getOutputSizeImpl(obj)
        %
        %   Inputs:
        %       ~ - Unused System object.
        %
        %   Outputs:
        %       sz - Size vector [1, 1].
        %
        %   Example:
        %       % Queried during model compilation.
        %
        %   See also: GETOUTPUTDATATYPEIMPL

            sz = [1, 1];
        end

        function dt = getOutputDataTypeImpl(~)
        %GETOUTPUTDATATYPEIMPL - ADC output data type is uint16.
        %   Returns the string "uint16".
        %
        %   Syntax:
        %       dt = getOutputDataTypeImpl(obj)
        %
        %   Inputs:
        %       ~ - Unused System object.
        %
        %   Outputs:
        %       dt - Data type name "uint16".
        %
        %   Example:
        %       % Queried during model compilation.
        %
        %   See also: GETOUTPUTSIZEIMPL

            dt = "uint16";
        end

        function c = isOutputComplexImpl(~)
        %ISOUTPUTCOMPLEXIMPL - ADC output is real-valued.
        %   Always returns false.
        %
        %   Syntax:
        %       c = isOutputComplexImpl(obj)
        %
        %   Inputs:
        %       ~ - Unused System object.
        %
        %   Outputs:
        %       c - false (not complex).
        %
        %   Example:
        %       % Queried during model compilation.
        %
        %   See also: ISOUTPUTFIXEDSIZEIMPL

            c = false;
        end

        function f = isOutputFixedSizeImpl(~)
        %ISOUTPUTFIXEDSIZEIMPL - ADC output has fixed size.
        %   Always returns true.
        %
        %   Syntax:
        %       f = isOutputFixedSizeImpl(obj)
        %
        %   Inputs:
        %       ~ - Unused System object.
        %
        %   Outputs:
        %       f - true (fixed size).
        %
        %   Example:
        %       % Queried during model compilation.
        %
        %   See also: ISOUTPUTCOMPLEXIMPL

            f = true;
        end

        function icon = getIconImpl(obj)
        %GETICONIMPL - Build the block icon including the ADC pin.
        %   Returns arduinopio.iconWithPin("Analog Input AVR", obj.Pin).
        %
        %   Syntax:
        %       icon = getIconImpl(obj)
        %
        %   Inputs:
        %       obj - AnalogInputAvr System object.
        %
        %   Outputs:
        %       icon - Icon line(s) for the Simulink block mask.
        %
        %   Example:
        %       % Queried when drawing the System block icon.
        %
        %   See also: ICONWITHPIN

            icon = arduinopio.iconWithPin("Analog Input AVR", obj.Pin);
        end

        function sts = getSampleTimeImpl(obj)
        %GETSAMPLETIMEIMPL - Inherited or discrete sample time from SampleTime.
        %   If SampleTime is -1, creates Inherited sample time; otherwise
        %   Discrete with SampleTime equal to obj.SampleTime.
        %
        %   Syntax:
        %       sts = getSampleTimeImpl(obj)
        %
        %   Inputs:
        %       obj - AnalogInputAvr System object.
        %
        %   Outputs:
        %       sts - Sample time specification from createSampleTime.
        %
        %   Example:
        %       % Queried during model compilation.
        %
        %   See also: CREATESAMPLETIME

            if obj.SampleTime == -1
                sts = createSampleTime(obj, Type="Inherited");
            else
                sts = createSampleTime(obj, Type="Discrete", SampleTime=obj.SampleTime);
            end
        end
    end

    methods (Static)
        function name = getDescriptiveName(~)
        %GETDESCRIPTIVENAME - Return the codegen name for Analog Input AVR.
        %   Returns the string "Arduino PIO Analog Input AVR".
        %
        %   Syntax:
        %       name = getDescriptiveName(codeInfo)
        %
        %   Inputs:
        %       ~ - Unused code information argument.
        %
        %   Outputs:
        %       name - Descriptive name string.
        %
        %   Example:
        %       % Called by coder.ExternalDependency during build.
        %
        %   See also: ISSUPPORTEDCONTEXT, UPDATEBUILDINFO

            name = "Arduino PIO Analog Input AVR";
        end

        function tf = isSupportedContext(context)
        %ISSUPPORTEDCONTEXT - True when the build context targets RTW.
        %   Returns context.isCodeGenTarget("rtw").
        %
        %   Syntax:
        %       tf = isSupportedContext(context)
        %
        %   Inputs:
        %       context - Code generation context object.
        %
        %   Outputs:
        %       tf - Logical true for RTW codegen targets.
        %
        %   Example:
        %       % Called by coder.ExternalDependency during build.
        %
        %   See also: GETDESCRIPTIVENAME, UPDATEBUILDINFO

            tf = context.isCodeGenTarget("rtw");
        end

        function updateBuildInfo(buildInfo, context)
        %UPDATEBUILDINFO - Register arduinopio_adc_avr.cpp for codegen.
        %   Calls arduinopio.updateDriverBuildInfo with source
        %   "arduinopio_adc_avr.cpp".
        %
        %   Syntax:
        %       updateBuildInfo(buildInfo, context)
        %
        %   Inputs:
        %       buildInfo - RTW.BuildInfo object to update.
        %       context   - Code generation context object.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       % Called by coder.ExternalDependency during build.
        %
        %   See also: UPDATEDRIVERBUILDINFO

            arduinopio.updateDriverBuildInfo(buildInfo, context, "arduinopio_adc_avr.cpp");
        end
    end

    methods (Static, Access = protected)
        function header = getHeaderImpl()
        %GETHEADERIMPL - System block dialog header for ADC AVR options.
        %   Returns matlab.system.display.Header for
        %   "arduinopio.blocks.avr.AnalogInputAvr" titled "Analog Input AVR"
        %   documenting ReferenceSelect and PrescalerSelect mappings.
        %
        %   Syntax:
        %       header = getHeaderImpl()
        %
        %   Inputs:
        %       none
        %
        %   Outputs:
        %       header - matlab.system.display.Header for the block dialog.
        %
        %   Example:
        %       % Queried when opening the System block dialog.
        %
        %   See also: MATLAB.SYSTEM.DISPLAY.HEADER

            header = matlab.system.display.Header( ...
                "arduinopio.blocks.avr.AnalogInputAvr", ...
                Title="Analog Input AVR", ...
                Text="ReferenceSelect: 0=AREF, 1=AVcc, 3=internal 1.1 V. PrescalerSelect 1-7 maps to /2../128.");
        end
    end
end
