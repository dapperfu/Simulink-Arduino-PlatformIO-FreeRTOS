classdef (Sealed) AnalogInput < matlab.System & coder.ExternalDependency
    %ANALOGINPUT - Measure voltage on an Arduino analog input pin as a 10-bit ADC count.
    %   Sealed matlab.System and coder.ExternalDependency for analog-read codegen. The Common
    %   library block uses the Level-2 MATLAB S-function arduinopio_analog_input instead of this
    %   System object. There is no setupImpl; stepImpl includes arduinopio_arduino.h and calls
    %   analogRead when coder.target("Rtw"). SampleTime -1 inherits; otherwise discrete. Host
    %   simulation returns uint16(0) and does not touch hardware. Nontunable Pin default 0 and
    %   SampleTime default -1.
    %
    %   Syntax:
    %       obj = arduinopio.blocks.common.AnalogInput
    %       obj = arduinopio.blocks.common.AnalogInput(Pin=0, SampleTime=-1)
    %
    %   Inputs:
    %       Pin - (1,1) nonnegative integer, default 0, validated as "analog" by validatePin.
    %       SampleTime - (1,1) double, default -1 (inherited) or positive discrete period.
    %
    %   Outputs:
    %       obj - Sealed matlab.System object. Step has 0 inputs and 1 uint16 output (0-1023).
    %
    %   Example:
    %       obj = arduinopio.blocks.common.AnalogInput(Pin=0);
    %
    %   Other m-files required: arduinopio.validatePin, arduinopio.iconWithPin,
    %       arduinopio.updateDriverBuildInfo
    %   Subfunctions: none
    %   MAT-files required: none
    %
    %   See also: DIGITALINPUT, VALIDATEPIN, ICONWITHPIN, UPDATEDRIVERBUILDINFO

    %   Author: Frey, Jed
    %   28-Sep-2026; Last revision: 28-Sep-2026

    properties (Nontunable)
        Pin (1,1) {mustBeInteger, mustBeNonnegative} = 0
        SampleTime (1,1) double = -1
    end

    methods
        function obj = AnalogInput(varargin)
        %ANALOGINPUT - Construct AnalogInput and apply Name-Value properties.
        %   Enables plain P-code via coder.allowpcode("plain"), then setProperties with varargin.
        %
        %   Syntax:
        %       obj = AnalogInput(varargin)
        %
        %   Inputs:
        %       varargin - Name-Value pairs for nontunable properties (Pin, SampleTime).
        %
        %   Outputs:
        %       obj - AnalogInput system object.
        %
        %   Example:
        %       obj = arduinopio.blocks.common.AnalogInput(Pin=0);
        %
        %   See also: ANALOGINPUT, SETPROPERTIES
            coder.allowpcode("plain");
            setProperties(obj, nargin, varargin{:});
        end
    end

    methods (Access = protected)
        function validatePropertiesImpl(obj)
        %VALIDATEPROPERTIESIMPL - Validate Pin as an analog Arduino pin.
        %   Calls arduinopio.validatePin(obj.Pin, "analog").
        %
        %   Syntax:
        %       validatePropertiesImpl(obj)
        %
        %   Inputs:
        %       obj - AnalogInput system object.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       % Invoked by the System object framework before setup.
        %
        %   See also: ANALOGINPUT, VALIDATEPIN
            arduinopio.validatePin(obj.Pin, "analog");
        end

        function y = stepImpl(obj)
        %STEPIMPL - Read the ADC with analogRead when generating code.
        %   Default y is uint16(0). Under coder.target("Rtw"), includes arduinopio_arduino.h,
        %   calls analogRead(uint8(obj.Pin)), and casts the int32 result to uint16. Host
        %   simulation leaves y at zero and does not access hardware.
        %
        %   Syntax:
        %       y = stepImpl(obj)
        %
        %   Inputs:
        %       obj - AnalogInput system object.
        %
        %   Outputs:
        %       y - (1,1) uint16 ADC count; 0 on host, analogRead result under RTW.
        %
        %   Example:
        %       % Invoked by the System object step method during codegen.
        %
        %   See also: ANALOGINPUT, VALIDATEPROPERTIESIMPL
            y = uint16(0);
            if coder.target("Rtw")
                value = int32(0);
                coder.cinclude("arduinopio_arduino.h");
                value = coder.ceval("analogRead", uint8(obj.Pin));
                y = uint16(value);
            end
        end

        function num = getNumInputsImpl(~)
        %GETNUMINPUTSIMPL - Report zero System object step inputs.
        %
        %   Syntax:
        %       num = getNumInputsImpl(~)
        %
        %   Inputs:
        %       ~ - Unused system object.
        %
        %   Outputs:
        %       num - 0.
        %
        %   Example:
        %       % Queried by Simulink for port counts.
        %
        %   See also: ANALOGINPUT, GETNUMOUTPUTSIMPL
            num = 0;
        end

        function num = getNumOutputsImpl(~)
        %GETNUMOUTPUTSIMPL - Report one System object step output.
        %
        %   Syntax:
        %       num = getNumOutputsImpl(~)
        %
        %   Inputs:
        %       ~ - Unused system object.
        %
        %   Outputs:
        %       num - 1.
        %
        %   Example:
        %       % Queried by Simulink for port counts.
        %
        %   See also: ANALOGINPUT, GETNUMINPUTSIMPL
            num = 1;
        end

        function out = getOutputSizeImpl(~)
        %GETOUTPUTSIZEIMPL - Return fixed output size [1, 1].
        %
        %   Syntax:
        %       out = getOutputSizeImpl(~)
        %
        %   Inputs:
        %       ~ - Unused system object.
        %
        %   Outputs:
        %       out - [1, 1].
        %
        %   Example:
        %       % Queried by Simulink for signal sizes.
        %
        %   See also: ANALOGINPUT, GETOUTPUTDATATYPEIMPL
            out = [1, 1];
        end

        function out = getOutputDataTypeImpl(~)
        %GETOUTPUTDATATYPEIMPL - Return output data type uint16.
        %
        %   Syntax:
        %       out = getOutputDataTypeImpl(~)
        %
        %   Inputs:
        %       ~ - Unused system object.
        %
        %   Outputs:
        %       out - "uint16".
        %
        %   Example:
        %       % Queried by Simulink for signal types.
        %
        %   See also: ANALOGINPUT, GETOUTPUTSIZEIMPL
            out = "uint16";
        end

        function out = isOutputComplexImpl(~)
        %ISOUTPUTCOMPLEXIMPL - Report that the output is real-valued.
        %
        %   Syntax:
        %       out = isOutputComplexImpl(~)
        %
        %   Inputs:
        %       ~ - Unused system object.
        %
        %   Outputs:
        %       out - false.
        %
        %   Example:
        %       % Queried by Simulink for complexity.
        %
        %   See also: ANALOGINPUT, ISOUTPUTFIXEDSIZEIMPL
            out = false;
        end

        function out = isOutputFixedSizeImpl(~)
        %ISOUTPUTFIXEDSIZEIMPL - Report that the output size is fixed.
        %
        %   Syntax:
        %       out = isOutputFixedSizeImpl(~)
        %
        %   Inputs:
        %       ~ - Unused system object.
        %
        %   Outputs:
        %       out - true.
        %
        %   Example:
        %       % Queried by Simulink for size mutability.
        %
        %   See also: ANALOGINPUT, ISOUTPUTCOMPLEXIMPL
            out = true;
        end

        function icon = getIconImpl(obj)
        %GETICONIMPL - Build the block icon string with the configured pin.
        %   Calls arduinopio.iconWithPin("Analog Input", obj.Pin).
        %
        %   Syntax:
        %       icon = getIconImpl(obj)
        %
        %   Inputs:
        %       obj - AnalogInput system object.
        %
        %   Outputs:
        %       icon - Icon text from iconWithPin.
        %
        %   Example:
        %       % Used by Simulink to label the MATLAB System block.
        %
        %   See also: ANALOGINPUT, ICONWITHPIN
            icon = arduinopio.iconWithPin("Analog Input", obj.Pin);
        end

        function sts = getSampleTimeImpl(obj)
        %GETSAMPLETIMEIMPL - Inherited sample time when SampleTime is -1, else discrete.
        %   Uses createSampleTime Type="Inherited" or Type="Discrete" with obj.SampleTime.
        %
        %   Syntax:
        %       sts = getSampleTimeImpl(obj)
        %
        %   Inputs:
        %       obj - AnalogInput system object.
        %
        %   Outputs:
        %       sts - Sample time specification object.
        %
        %   Example:
        %       % Queried by Simulink for sample-time propagation.
        %
        %   See also: ANALOGINPUT, CREATESAMPLETIME
            if obj.SampleTime == -1
                sts = createSampleTime(obj, Type="Inherited");
            else
                sts = createSampleTime(obj, Type="Discrete", SampleTime=obj.SampleTime);
            end
        end
    end

    methods (Static)
        function name = getDescriptiveName(~)
        %GETDESCRIPTIVENAME - Return the short descriptive name for this dependency.
        %
        %   Syntax:
        %       name = getDescriptiveName(~)
        %
        %   Inputs:
        %       ~ - Unused context argument.
        %
        %   Outputs:
        %       name - "Arduino PIO Analog Input".
        %
        %   Example:
        %       % Used by coder.ExternalDependency tooling.
        %
        %   See also: ANALOGINPUT, ISSUPPORTEDCONTEXT
            name = "Arduino PIO Analog Input";
        end

        function tf = isSupportedContext(context)
        %ISSUPPORTEDCONTEXT - True when the build context is an RTW code-generation target.
        %
        %   Syntax:
        %       tf = isSupportedContext(context)
        %
        %   Inputs:
        %       context - Codegen context with isCodeGenTarget.
        %
        %   Outputs:
        %       tf - true if context.isCodeGenTarget("rtw").
        %
        %   Example:
        %       % Called by coder.ExternalDependency during builds.
        %
        %   See also: ANALOGINPUT, UPDATEBUILDINFO
            tf = context.isCodeGenTarget("rtw");
        end

        function updateBuildInfo(buildInfo, context)
        %UPDATEBUILDINFO - Add Arduino PIO driver sources and include paths.
        %   Delegates to arduinopio.updateDriverBuildInfo(buildInfo, context).
        %
        %   Syntax:
        %       updateBuildInfo(buildInfo, context)
        %
        %   Inputs:
        %       buildInfo - RTW build information object.
        %       context - Codegen build context.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       % Invoked during code generation link steps.
        %
        %   See also: ANALOGINPUT, UPDATEDRIVERBUILDINFO
            arduinopio.updateDriverBuildInfo(buildInfo, context);
        end
    end

    methods (Static, Access = protected)
        function header = getHeaderImpl()
        %GETHEADERIMPL - Dialog header title and help text for the System block mask.
        %   Returns matlab.system.display.Header for arduinopio.blocks.common.AnalogInput with
        %   Title "Analog Input" and Text describing Uno A0-A5 as pins 0-5 and 0-1023 ADC range.
        %
        %   Syntax:
        %       header = getHeaderImpl()
        %
        %   Inputs:
        %       none
        %
        %   Outputs:
        %       header - matlab.system.display.Header object.
        %
        %   Example:
        %       % Used by the MATLAB System block property dialog.
        %
        %   See also: ANALOGINPUT
            header = matlab.system.display.Header( ...
                "arduinopio.blocks.common.AnalogInput", ...
                Title="Analog Input", ...
                Text="Uno A0-A5 as pin 0-5. Output is 0-1023 for a 10-bit ADC.");
        end
    end
end
