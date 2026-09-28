classdef (Sealed) ExternalInterrupt < matlab.System & coder.ExternalDependency
    %EXTERNALINTERRUPT - Detect an external pin interrupt; output true when an event is pending.
    %   Sealed matlab.System and coder.ExternalDependency for ext-int codegen. setupImpl includes
    %   arduinopio_extint.h and calls arduinopioExtIntSetup with Pin, Mode, and pinPullIndex.
    %   stepImpl under RTW calls arduinopioExtIntTake; on host returns logical(simIrq). SampleTime
    %   -1 inherits; otherwise discrete. Nontunable Pin default 2, Mode default 3 (RISING),
    %   PinPull default 'None', SampleTime default -1. Mode: 0=LOW, 1=CHANGE, 2=FALLING, 3=RISING.
    %
    %   Syntax:
    %       obj = arduinopio.blocks.common.ExternalInterrupt
    %       obj = arduinopio.blocks.common.ExternalInterrupt(Pin=2, Mode=3, PinPull='None', ...
    %           SampleTime=-1)
    %
    %   Inputs:
    %       Pin - (1,1) nonnegative integer, default 2, validated as "interrupt" by validatePin.
    %       Mode - integer in [0, 1, 2, 3], default 3; interrupt sense mode.
    %       PinPull - 'None', 'Pull-up', or 'Pull-down' (StringSet); validated by validatePinPull.
    %       SampleTime - (1,1) double, default -1 (inherited) or positive discrete period.
    %
    %   Outputs:
    %       obj - Sealed matlab.System. Step has 1 simIrq input and 1 logical pending output.
    %
    %   Example:
    %       obj = arduinopio.blocks.common.ExternalInterrupt(Pin=2, Mode=3);
    %
    %   Other m-files required: arduinopio.validatePin, arduinopio.validatePinPull,
    %       arduinopio.pinPullIndex, arduinopio.iconWithPin, arduinopio.updateDriverBuildInfo
    %   Subfunctions: none
    %   MAT-files required: none
    %
    %   See also: ENCODER, VALIDATEPIN, VALIDATEPINPULL, PINPULLINDEX, ICONWITHPIN

    %   Author: Frey, Jed
    %   28-Sep-2026; Last revision: 28-Sep-2026

    properties (Nontunable)
        Pin (1,1) {mustBeInteger, mustBeNonnegative} = 2
        Mode (1,1) {mustBeInteger, mustBeMember(Mode, [0, 1, 2, 3])} = 3
        % Internal resistor
        PinPull = 'None'
        SampleTime (1,1) double = -1
    end

    properties (Constant, Hidden)
        PinPullSet = matlab.system.StringSet({'None', 'Pull-up', 'Pull-down'})
    end

    methods
        function obj = ExternalInterrupt(varargin)
        %EXTERNALINTERRUPT - Construct ExternalInterrupt and apply Name-Value properties.
        %   Enables plain P-code via coder.allowpcode("plain"), then setProperties with varargin.
        %
        %   Syntax:
        %       obj = ExternalInterrupt(varargin)
        %
        %   Inputs:
        %       varargin - Name-Value pairs for nontunable properties (Pin, Mode, PinPull,
        %           SampleTime).
        %
        %   Outputs:
        %       obj - ExternalInterrupt system object.
        %
        %   Example:
        %       obj = arduinopio.blocks.common.ExternalInterrupt(Pin=2);
        %
        %   See also: EXTERNALINTERRUPT, SETPROPERTIES
            coder.allowpcode("plain");
            setProperties(obj, nargin, varargin{:});
        end
    end

    methods (Access = protected)
        function validatePropertiesImpl(obj)
        %VALIDATEPROPERTIESIMPL - Validate interrupt Pin and PinPull.
        %   Calls validatePin(obj.Pin, "interrupt") and validatePinPull(obj.PinPull).
        %
        %   Syntax:
        %       validatePropertiesImpl(obj)
        %
        %   Inputs:
        %       obj - ExternalInterrupt system object.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       % Invoked by the System object framework before setup.
        %
        %   See also: EXTERNALINTERRUPT, VALIDATEPIN, VALIDATEPINPULL
            arduinopio.validatePin(obj.Pin, "interrupt");
            arduinopio.validatePinPull(obj.PinPull);
        end

        function setupImpl(obj)
        %SETUPIMPL - Arm the external interrupt via arduinopioExtIntSetup under RTW.
        %   Under coder.target("Rtw"), includes arduinopio_extint.h and cevals
        %   arduinopioExtIntSetup(Pin, Mode, pinPullIndex(PinPull)). Host is a no-op.
        %
        %   Syntax:
        %       setupImpl(obj)
        %
        %   Inputs:
        %       obj - ExternalInterrupt system object.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       % Invoked once before stepping during codegen.
        %
        %   See also: EXTERNALINTERRUPT, STEPIMPL
            if coder.target("Rtw")
                coder.cinclude("arduinopio_extint.h");
                coder.ceval("arduinopioExtIntSetup", uint8(obj.Pin), uint8(obj.Mode), ...
                    uint8(arduinopio.pinPullIndex(obj.PinPull)));
            end
        end

        function y = stepImpl(obj, simIrq)
        %STEPIMPL - Take a pending interrupt flag under RTW, or echo simIrq on host.
        %   Under coder.target("Rtw"), cevals arduinopioExtIntTake(uint8(obj.Pin)) and sets
        %   y = (pending ~= 0). Otherwise y = logical(simIrq) for host simulation.
        %
        %   Syntax:
        %       y = stepImpl(obj, simIrq)
        %
        %   Inputs:
        %       obj - ExternalInterrupt system object.
        %       simIrq - Host-simulation interrupt inject; used only when not targeting RTW.
        %
        %   Outputs:
        %       y - (1,1) logical true when an interrupt event is pending (or simIrq on host).
        %
        %   Example:
        %       % Invoked by the System object step method during codegen.
        %
        %   See also: EXTERNALINTERRUPT, SETUPIMPL
            if coder.target("Rtw")
                pending = uint8(0);
                pending = coder.ceval("arduinopioExtIntTake", uint8(obj.Pin));
                y = (pending ~= 0);
            else
                y = logical(simIrq);
            end
        end

        function num = getNumInputsImpl(~)
        %GETNUMINPUTSIMPL - Report one System object step input.
        %
        %   Syntax:
        %       num = getNumInputsImpl(~)
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
        %   See also: EXTERNALINTERRUPT, GETNUMOUTPUTSIMPL
            num = 1;
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
        %   See also: EXTERNALINTERRUPT, GETNUMINPUTSIMPL
            num = 1;
        end

        function sz = getOutputSizeImpl(~)
        %GETOUTPUTSIZEIMPL - Return fixed output size [1, 1].
        %
        %   Syntax:
        %       sz = getOutputSizeImpl(~)
        %
        %   Inputs:
        %       ~ - Unused system object.
        %
        %   Outputs:
        %       sz - [1, 1].
        %
        %   Example:
        %       % Queried by Simulink for signal sizes.
        %
        %   See also: EXTERNALINTERRUPT, GETOUTPUTDATATYPEIMPL
            sz = [1, 1];
        end

        function dt = getOutputDataTypeImpl(~)
        %GETOUTPUTDATATYPEIMPL - Return output data type logical.
        %
        %   Syntax:
        %       dt = getOutputDataTypeImpl(~)
        %
        %   Inputs:
        %       ~ - Unused system object.
        %
        %   Outputs:
        %       dt - "logical".
        %
        %   Example:
        %       % Queried by Simulink for signal types.
        %
        %   See also: EXTERNALINTERRUPT, GETOUTPUTSIZEIMPL
            dt = "logical";
        end

        function c = isOutputComplexImpl(~)
        %ISOUTPUTCOMPLEXIMPL - Report that the output is real-valued.
        %
        %   Syntax:
        %       c = isOutputComplexImpl(~)
        %
        %   Inputs:
        %       ~ - Unused system object.
        %
        %   Outputs:
        %       c - false.
        %
        %   Example:
        %       % Queried by Simulink for complexity.
        %
        %   See also: EXTERNALINTERRUPT, ISOUTPUTFIXEDSIZEIMPL
            c = false;
        end

        function f = isOutputFixedSizeImpl(~)
        %ISOUTPUTFIXEDSIZEIMPL - Report that the output size is fixed.
        %
        %   Syntax:
        %       f = isOutputFixedSizeImpl(~)
        %
        %   Inputs:
        %       ~ - Unused system object.
        %
        %   Outputs:
        %       f - true.
        %
        %   Example:
        %       % Queried by Simulink for size mutability.
        %
        %   See also: EXTERNALINTERRUPT, ISOUTPUTCOMPLEXIMPL
            f = true;
        end

        function icon = getIconImpl(obj)
        %GETICONIMPL - Build the block icon string with the configured pin.
        %   Calls arduinopio.iconWithPin("External Interrupt", obj.Pin).
        %
        %   Syntax:
        %       icon = getIconImpl(obj)
        %
        %   Inputs:
        %       obj - ExternalInterrupt system object.
        %
        %   Outputs:
        %       icon - Icon text from iconWithPin.
        %
        %   Example:
        %       % Used by Simulink to label the MATLAB System block.
        %
        %   See also: EXTERNALINTERRUPT, ICONWITHPIN
            icon = arduinopio.iconWithPin("External Interrupt", obj.Pin);
        end

        function sts = getSampleTimeImpl(obj)
        %GETSAMPLETIMEIMPL - Inherited sample time when SampleTime is -1, else discrete.
        %   Uses createSampleTime Type="Inherited" or Type="Discrete" with obj.SampleTime.
        %
        %   Syntax:
        %       sts = getSampleTimeImpl(obj)
        %
        %   Inputs:
        %       obj - ExternalInterrupt system object.
        %
        %   Outputs:
        %       sts - Sample time specification object.
        %
        %   Example:
        %       % Queried by Simulink for sample-time propagation.
        %
        %   See also: EXTERNALINTERRUPT, CREATESAMPLETIME
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
        %       name - "Arduino PIO External Interrupt".
        %
        %   Example:
        %       % Used by coder.ExternalDependency tooling.
        %
        %   See also: EXTERNALINTERRUPT, ISSUPPORTEDCONTEXT
            name = "Arduino PIO External Interrupt";
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
        %   See also: EXTERNALINTERRUPT, UPDATEBUILDINFO
            tf = context.isCodeGenTarget("rtw");
        end

        function updateBuildInfo(buildInfo, context)
        %UPDATEBUILDINFO - Add external-interrupt driver source to the RTW build.
        %   Calls updateDriverBuildInfo(buildInfo, context, "arduinopio_extint.cpp").
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
        %   See also: EXTERNALINTERRUPT, UPDATEDRIVERBUILDINFO
            arduinopio.updateDriverBuildInfo(buildInfo, context, "arduinopio_extint.cpp");
        end
    end

    methods (Static, Access = protected)
        function header = getHeaderImpl()
        %GETHEADERIMPL - Dialog header title and help text for the System block mask.
        %   Returns Header for ExternalInterrupt: Uno INT0/INT1 pins, Mode codes, and resistor
        %   options None / Pull-up / Pull-down.
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
        %   See also: EXTERNALINTERRUPT
            header = matlab.system.display.Header( ...
                "arduinopio.blocks.common.ExternalInterrupt", ...
                Title="External Interrupt", ...
                Text="Uno pins 2 (INT0) and 3 (INT1). Mode: 0=LOW, 1=CHANGE, 2=FALLING, 3=RISING. Internal resistor: None, Pull-up, or Pull-down.");
        end
    end
end
