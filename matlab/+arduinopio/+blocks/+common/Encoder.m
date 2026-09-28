classdef (Sealed) Encoder < matlab.System & coder.ExternalDependency
    %ENCODER - Measure quadrature encoder ticks on two Arduino interrupt pins.
    %   Sealed matlab.System and coder.ExternalDependency for encoder codegen. Uno interrupt pins
    %   are 2 and 3. setupImpl includes arduinopio_encoder.h and calls arduinopioEncoderSetup.
    %   stepImpl calls arduinopioEncoderRead with ResetEachSample when coder.target("Rtw").
    %   SampleTime -1 inherits; otherwise discrete. Host simulation returns int32(0) and does not
    %   touch hardware. Nontunable PinA default 2, PinB default 3, ResetEachSample false,
    %   SampleTime -1. PinA and PinB must differ and both validate as "interrupt".
    %
    %   Syntax:
    %       obj = arduinopio.blocks.common.Encoder
    %       obj = arduinopio.blocks.common.Encoder(PinA=2, PinB=3, ResetEachSample=false, ...
    %           SampleTime=-1)
    %
    %   Inputs:
    %       PinA - (1,1) nonnegative integer, default 2, validated as "interrupt".
    %       PinB - (1,1) nonnegative integer, default 3, validated as "interrupt"; must differ.
    %       ResetEachSample - (1,1) logical, default false; passed to arduinopioEncoderRead.
    %       SampleTime - (1,1) double, default -1 (inherited) or positive discrete period.
    %
    %   Outputs:
    %       obj - Sealed matlab.System object. Step has 0 inputs and 1 int32 tick count output.
    %
    %   Example:
    %       obj = arduinopio.blocks.common.Encoder(PinA=2, PinB=3);
    %
    %   Other m-files required: arduinopio.validatePin, arduinopio.iconWithPin,
    %       arduinopio.updateDriverBuildInfo
    %   Subfunctions: none
    %   MAT-files required: none
    %
    %   See also: EXTERNALINTERRUPT, VALIDATEPIN, ICONWITHPIN, UPDATEDRIVERBUILDINFO

    %   Author: Frey, Jed
    %   28-Sep-2026; Last revision: 28-Sep-2026

    properties (Nontunable)
        PinA (1,1) {mustBeInteger, mustBeNonnegative} = 2
        PinB (1,1) {mustBeInteger, mustBeNonnegative} = 3
        ResetEachSample (1,1) logical = false
        SampleTime (1,1) double = -1
    end

    methods
        function obj = Encoder(varargin)
        %ENCODER - Construct Encoder and apply Name-Value properties.
        %   Enables plain P-code via coder.allowpcode("plain"), then setProperties with varargin.
        %
        %   Syntax:
        %       obj = Encoder(varargin)
        %
        %   Inputs:
        %       varargin - Name-Value pairs for nontunable properties (PinA, PinB,
        %           ResetEachSample, SampleTime).
        %
        %   Outputs:
        %       obj - Encoder system object.
        %
        %   Example:
        %       obj = arduinopio.blocks.common.Encoder(PinA=2, PinB=3);
        %
        %   See also: ENCODER, SETPROPERTIES
            coder.allowpcode("plain");
            setProperties(obj, nargin, varargin{:});
        end
    end

    methods (Access = protected)
        function validatePropertiesImpl(obj)
        %VALIDATEPROPERTIESIMPL - Validate interrupt pins and require PinA ~= PinB.
        %   validatePin for PinA and PinB as "interrupt"; errors arduinopio:EncoderPins if equal.
        %
        %   Syntax:
        %       validatePropertiesImpl(obj)
        %
        %   Inputs:
        %       obj - Encoder system object.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       % Invoked by the System object framework before setup.
        %
        %   See also: ENCODER, VALIDATEPIN
            arduinopio.validatePin(obj.PinA, "interrupt");
            arduinopio.validatePin(obj.PinB, "interrupt");
            if obj.PinA == obj.PinB
                error("arduinopio:EncoderPins", ...
                    "Encoder pins A and B must be different. Use Uno interrupt pins 2 and 3.");
            end
        end

        function setupImpl(obj)
        %SETUPIMPL - Attach quadrature channels via arduinopioEncoderSetup under RTW.
        %   Under coder.target("Rtw"), includes arduinopio_encoder.h and calls
        %   arduinopioEncoderSetup(uint8(PinA), uint8(PinB)). Host simulation is a no-op.
        %
        %   Syntax:
        %       setupImpl(obj)
        %
        %   Inputs:
        %       obj - Encoder system object.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       % Invoked once before stepping during codegen.
        %
        %   See also: ENCODER, STEPIMPL
            if coder.target("Rtw")
                coder.cinclude("arduinopio_encoder.h");
                coder.ceval("arduinopioEncoderSetup", uint8(obj.PinA), uint8(obj.PinB));
            end
        end

        function y = stepImpl(obj)
        %STEPIMPL - Read tick count with arduinopioEncoderRead when generating code.
        %   Default y is int32(0). Under coder.target("Rtw"), y =
        %   coder.ceval("arduinopioEncoderRead", uint8(obj.ResetEachSample)). Host leaves zero.
        %
        %   Syntax:
        %       y = stepImpl(obj)
        %
        %   Inputs:
        %       obj - Encoder system object.
        %
        %   Outputs:
        %       y - (1,1) int32 tick count; 0 on host, driver read under RTW.
        %
        %   Example:
        %       % Invoked by the System object step method during codegen.
        %
        %   See also: ENCODER, SETUPIMPL
            y = int32(0);
            if coder.target("Rtw")
                y = coder.ceval("arduinopioEncoderRead", uint8(obj.ResetEachSample));
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
        %   See also: ENCODER, GETNUMOUTPUTSIMPL
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
        %   See also: ENCODER, GETNUMINPUTSIMPL
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
        %   See also: ENCODER, GETOUTPUTDATATYPEIMPL
            sz = [1, 1];
        end

        function dt = getOutputDataTypeImpl(~)
        %GETOUTPUTDATATYPEIMPL - Return output data type int32.
        %
        %   Syntax:
        %       dt = getOutputDataTypeImpl(~)
        %
        %   Inputs:
        %       ~ - Unused system object.
        %
        %   Outputs:
        %       dt - "int32".
        %
        %   Example:
        %       % Queried by Simulink for signal types.
        %
        %   See also: ENCODER, GETOUTPUTSIZEIMPL
            dt = "int32";
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
        %   See also: ENCODER, ISOUTPUTFIXEDSIZEIMPL
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
        %   See also: ENCODER, ISOUTPUTCOMPLEXIMPL
            f = true;
        end

        function icon = getIconImpl(obj)
        %GETICONIMPL - Build the block icon with both encoder pins.
        %   Calls arduinopio.iconWithPin("Encoder", [obj.PinA, obj.PinB]).
        %
        %   Syntax:
        %       icon = getIconImpl(obj)
        %
        %   Inputs:
        %       obj - Encoder system object.
        %
        %   Outputs:
        %       icon - Icon text from iconWithPin.
        %
        %   Example:
        %       % Used by Simulink to label the MATLAB System block.
        %
        %   See also: ENCODER, ICONWITHPIN
            icon = arduinopio.iconWithPin("Encoder", [obj.PinA, obj.PinB]);
        end

        function sts = getSampleTimeImpl(obj)
        %GETSAMPLETIMEIMPL - Inherited sample time when SampleTime is -1, else discrete.
        %   Uses createSampleTime Type="Inherited" or Type="Discrete" with obj.SampleTime.
        %
        %   Syntax:
        %       sts = getSampleTimeImpl(obj)
        %
        %   Inputs:
        %       obj - Encoder system object.
        %
        %   Outputs:
        %       sts - Sample time specification object.
        %
        %   Example:
        %       % Queried by Simulink for sample-time propagation.
        %
        %   See also: ENCODER, CREATESAMPLETIME
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
        %       name - "Arduino PIO Encoder".
        %
        %   Example:
        %       % Used by coder.ExternalDependency tooling.
        %
        %   See also: ENCODER, ISSUPPORTEDCONTEXT
            name = "Arduino PIO Encoder";
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
        %   See also: ENCODER, UPDATEBUILDINFO
            tf = context.isCodeGenTarget("rtw");
        end

        function updateBuildInfo(buildInfo, context)
        %UPDATEBUILDINFO - Add encoder driver source to the RTW build.
        %   Calls updateDriverBuildInfo(buildInfo, context, "arduinopio_encoder.cpp").
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
        %   See also: ENCODER, UPDATEDRIVERBUILDINFO
            arduinopio.updateDriverBuildInfo(buildInfo, context, "arduinopio_encoder.cpp");
        end
    end
end
