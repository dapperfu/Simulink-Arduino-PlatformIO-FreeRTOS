classdef (Sealed) DigitalInput < matlab.System & coder.ExternalDependency
    %DIGITALINPUT - Read the logical state of an Arduino digital input pin.
    %   Sealed matlab.System and coder.ExternalDependency for digital-read codegen. The Common
    %   library block uses the Level-2 MATLAB S-function arduinopio_digital_input instead of this
    %   System object. setupImpl calls pinMode with INPUT, INPUT_PULLUP, or INPUT_PULLDOWN from
    %   PinPull; stepImpl calls digitalRead when coder.target("Rtw") and includes
    %   arduinopio_arduino.h. SampleTime -1 inherits; otherwise discrete. Host simulation returns
    %   logical(SimValue ~= 0) and does not touch hardware. Nontunable Pin default 2, PinPull
    %   default 'None', SampleTime default -1, SimValue default 0.
    %
    %   Syntax:
    %       obj = arduinopio.blocks.common.DigitalInput
    %       obj = arduinopio.blocks.common.DigitalInput(Pin=2, PinPull='None', SampleTime=-1, ...
    %           SimValue=0)
    %
    %   Inputs:
    %       Pin - (1,1) nonnegative integer, default 2, validated as "digital" by validatePin.
    %       PinPull - 'None', 'Pull-up', or 'Pull-down' (StringSet); validated by validatePinPull.
    %       SampleTime - (1,1) double, default -1 (inherited) or positive discrete period.
    %       SimValue - (1,1) double host simulation level; nonzero becomes true on host.
    %
    %   Outputs:
    %       obj - Sealed matlab.System object. Step has 0 inputs and 1 logical output.
    %
    %   Example:
    %       obj = arduinopio.blocks.common.DigitalInput(Pin=2, PinPull='Pull-up');
    %
    %   Other m-files required: arduinopio.validatePin, arduinopio.validatePinPull,
    %       arduinopio.iconWithPin, arduinopio.updateDriverBuildInfo
    %   Subfunctions: none
    %   MAT-files required: none
    %
    %   See also: DIGITALOUTPUT, VALIDATEPIN, VALIDATEPINPULL, ICONWITHPIN

    %   Author: Frey, Jed
    %   28-Sep-2026; Last revision: 28-Sep-2026

    properties (Nontunable)
        Pin (1,1) {mustBeInteger, mustBeNonnegative} = 2
        % Internal resistor
        PinPull = 'None'
        SampleTime (1,1) double = -1
        SimValue (1,1) double = 0
    end

    properties (Constant, Hidden)
        PinPullSet = matlab.system.StringSet({'None', 'Pull-up', 'Pull-down'})
    end

    methods
        function obj = DigitalInput(varargin)
        %DIGITALINPUT - Construct DigitalInput and apply Name-Value properties.
        %   Enables plain P-code via coder.allowpcode("plain"), then setProperties with varargin.
        %
        %   Syntax:
        %       obj = DigitalInput(varargin)
        %
        %   Inputs:
        %       varargin - Name-Value pairs for nontunable properties (Pin, PinPull, SampleTime,
        %           SimValue).
        %
        %   Outputs:
        %       obj - DigitalInput system object.
        %
        %   Example:
        %       obj = arduinopio.blocks.common.DigitalInput(Pin=2);
        %
        %   See also: DIGITALINPUT, SETPROPERTIES
            coder.allowpcode("plain");
            setProperties(obj, nargin, varargin{:});
        end
    end

    methods (Access = protected)
        function validatePropertiesImpl(obj)
        %VALIDATEPROPERTIESIMPL - Validate Pin and PinPull for digital input.
        %   Calls validatePin(obj.Pin, "digital") and validatePinPull(obj.PinPull).
        %
        %   Syntax:
        %       validatePropertiesImpl(obj)
        %
        %   Inputs:
        %       obj - DigitalInput system object.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       % Invoked by the System object framework before setup.
        %
        %   See also: DIGITALINPUT, VALIDATEPIN, VALIDATEPINPULL
            arduinopio.validatePin(obj.Pin, "digital");
            arduinopio.validatePinPull(obj.PinPull);
        end

        function setupImpl(obj)
        %SETUPIMPL - Configure pinMode INPUT, INPUT_PULLUP, or INPUT_PULLDOWN under RTW.
        %   Under coder.target("Rtw"), includes arduinopio_arduino.h and maps PinPull "Pull-up",
        %   "Pull-down", or otherwise to the matching opaque pinMode mode. Host is a no-op.
        %
        %   Syntax:
        %       setupImpl(obj)
        %
        %   Inputs:
        %       obj - DigitalInput system object.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       % Invoked once before stepping during codegen.
        %
        %   See also: DIGITALINPUT, STEPIMPL
            if coder.target("Rtw")
                coder.cinclude("arduinopio_arduino.h");
                pullName = char(obj.PinPull);
                if strcmp(pullName, "Pull-up")
                    coder.ceval("pinMode", uint8(obj.Pin), coder.opaque("uint8_t", "INPUT_PULLUP"));
                elseif strcmp(pullName, "Pull-down")
                    coder.ceval("pinMode", uint8(obj.Pin), coder.opaque("uint8_t", "INPUT_PULLDOWN"));
                else
                    coder.ceval("pinMode", uint8(obj.Pin), coder.opaque("uint8_t", "INPUT"));
                end
            end
        end

        function y = stepImpl(obj)
        %STEPIMPL - Read the pin with digitalRead when generating code.
        %   Host sets y = logical(obj.SimValue ~= 0). Under coder.target("Rtw"), includes
        %   arduinopio_arduino.h, calls digitalRead(uint8(obj.Pin)), and sets y = (value ~= 0).
        %
        %   Syntax:
        %       y = stepImpl(obj)
        %
        %   Inputs:
        %       obj - DigitalInput system object.
        %
        %   Outputs:
        %       y - (1,1) logical pin state; SimValue-based on host, digitalRead under RTW.
        %
        %   Example:
        %       % Invoked by the System object step method during codegen.
        %
        %   See also: DIGITALINPUT, SETUPIMPL
            y = logical(obj.SimValue ~= 0);
            if coder.target("Rtw")
                value = int32(0);
                coder.cinclude("arduinopio_arduino.h");
                value = coder.ceval("digitalRead", uint8(obj.Pin));
                y = (value ~= 0);
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
        %   See also: DIGITALINPUT, GETNUMOUTPUTSIMPL
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
        %   See also: DIGITALINPUT, GETNUMINPUTSIMPL
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
        %   See also: DIGITALINPUT, GETOUTPUTDATATYPEIMPL
            out = [1, 1];
        end

        function out = getOutputDataTypeImpl(~)
        %GETOUTPUTDATATYPEIMPL - Return output data type logical.
        %
        %   Syntax:
        %       out = getOutputDataTypeImpl(~)
        %
        %   Inputs:
        %       ~ - Unused system object.
        %
        %   Outputs:
        %       out - "logical".
        %
        %   Example:
        %       % Queried by Simulink for signal types.
        %
        %   See also: DIGITALINPUT, GETOUTPUTSIZEIMPL
            out = "logical";
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
        %   See also: DIGITALINPUT, ISOUTPUTFIXEDSIZEIMPL
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
        %   See also: DIGITALINPUT, ISOUTPUTCOMPLEXIMPL
            out = true;
        end

        function icon = getIconImpl(obj)
        %GETICONIMPL - Build the block icon string with the configured pin.
        %   Calls arduinopio.iconWithPin("Digital Input", obj.Pin).
        %
        %   Syntax:
        %       icon = getIconImpl(obj)
        %
        %   Inputs:
        %       obj - DigitalInput system object.
        %
        %   Outputs:
        %       icon - Icon text from iconWithPin.
        %
        %   Example:
        %       % Used by Simulink to label the MATLAB System block.
        %
        %   See also: DIGITALINPUT, ICONWITHPIN
            icon = arduinopio.iconWithPin("Digital Input", obj.Pin);
        end

        function sts = getSampleTimeImpl(obj)
        %GETSAMPLETIMEIMPL - Inherited sample time when SampleTime is -1, else discrete.
        %   Uses createSampleTime Type="Inherited" or Type="Discrete" with obj.SampleTime.
        %
        %   Syntax:
        %       sts = getSampleTimeImpl(obj)
        %
        %   Inputs:
        %       obj - DigitalInput system object.
        %
        %   Outputs:
        %       sts - Sample time specification object.
        %
        %   Example:
        %       % Queried by Simulink for sample-time propagation.
        %
        %   See also: DIGITALINPUT, CREATESAMPLETIME
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
        %       name - "Arduino PIO Digital Input".
        %
        %   Example:
        %       % Used by coder.ExternalDependency tooling.
        %
        %   See also: DIGITALINPUT, ISSUPPORTEDCONTEXT
            name = "Arduino PIO Digital Input";
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
        %   See also: DIGITALINPUT, UPDATEBUILDINFO
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
        %   See also: DIGITALINPUT, UPDATEDRIVERBUILDINFO
            arduinopio.updateDriverBuildInfo(buildInfo, context);
        end
    end

    methods (Static, Access = protected)
        function header = getHeaderImpl()
        %GETHEADERIMPL - Dialog header title and help text for the System block mask.
        %   Returns matlab.system.display.Header for arduinopio.blocks.common.DigitalInput with
        %   Title "Digital Input" and Text on ceval path and resistor options.
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
        %   See also: DIGITALINPUT
            header = matlab.system.display.Header( ...
                "arduinopio.blocks.common.DigitalInput", ...
                Title="Digital Input", ...
                Text="MATLAB System object path: setupImpl/stepImpl emit coder.ceval calls. Internal resistor: None, Pull-up, or Pull-down.");
        end
    end
end
