classdef (Sealed) ContinuousServoWrite < matlab.System & coder.ExternalDependency
    %CONTINUOUSSERVOWRITE - Drive continuous-rotation servo speed from -100 to 100 on a pin.
    %   Sealed matlab.System and coder.ExternalDependency using Timer1 on Uno. setupImpl includes
    %   arduinopio_servo.h and calls arduinopioServoSetup. stepImpl clamps the input to [-100,
    %   100] as int8 and calls arduinopioServoWriteSpeed when coder.target("Rtw"). SampleTime -1
    %   inherits; otherwise discrete. Host simulation is a no-op. Nontunable Pin default 9 and
    %   SampleTime default -1. validatePropertiesImpl warns about Timer1 conflicts with PWM on
    %   pins 9/10 and Input Capture on pin 8.
    %
    %   Syntax:
    %       obj = arduinopio.blocks.common.ContinuousServoWrite
    %       obj = arduinopio.blocks.common.ContinuousServoWrite(Pin=9, SampleTime=-1)
    %
    %   Inputs:
    %       Pin - (1,1) nonnegative integer, default 9, validated as "digital" by validatePin.
    %       SampleTime - (1,1) double, default -1 (inherited) or positive discrete period.
    %
    %   Outputs:
    %       obj - Sealed matlab.System object. Step has 1 speed input and 0 outputs.
    %
    %   Example:
    %       obj = arduinopio.blocks.common.ContinuousServoWrite(Pin=9);
    %
    %   Other m-files required: arduinopio.validatePin, arduinopio.warnIfNotLibrary,
    %       arduinopio.iconWithPin, arduinopio.updateDriverBuildInfo
    %   Subfunctions: none
    %   MAT-files required: none
    %
    %   See also: VALIDATEPIN, WARNIFNOTLIBRARY, ICONWITHPIN, UPDATEDRIVERBUILDINFO

    %   Author: Frey, Jed
    %   28-Sep-2026; Last revision: 28-Sep-2026

    properties (Nontunable)
        Pin (1,1) {mustBeInteger, mustBeNonnegative} = 9
        SampleTime (1,1) double = -1
    end

    methods
        function obj = ContinuousServoWrite(varargin)
        %CONTINUOUSSERVOWRITE - Construct ContinuousServoWrite and apply Name-Value properties.
        %   Enables plain P-code via coder.allowpcode("plain"), then setProperties with varargin.
        %
        %   Syntax:
        %       obj = ContinuousServoWrite(varargin)
        %
        %   Inputs:
        %       varargin - Name-Value pairs for nontunable properties (Pin, SampleTime).
        %
        %   Outputs:
        %       obj - ContinuousServoWrite system object.
        %
        %   Example:
        %       obj = arduinopio.blocks.common.ContinuousServoWrite(Pin=9);
        %
        %   See also: CONTINUOUSSERVOWRITE, SETPROPERTIES
            coder.allowpcode("plain");
            setProperties(obj, nargin, varargin{:});
        end
    end

    methods (Access = protected)
        function validatePropertiesImpl(obj)
        %VALIDATEPROPERTIESIMPL - Validate Pin and warn about Timer1 conflicts.
        %   validatePin(obj.Pin, "digital") and warnIfNotLibrary for Timer1Conflict: avoid PWM
        %   on pins 9 and 10 and Input Capture on pin 8.
        %
        %   Syntax:
        %       validatePropertiesImpl(obj)
        %
        %   Inputs:
        %       obj - ContinuousServoWrite system object.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       % Invoked by the System object framework before setup.
        %
        %   See also: CONTINUOUSSERVOWRITE, VALIDATEPIN, WARNIFNOTLIBRARY
            arduinopio.validatePin(obj.Pin, "digital");
            arduinopio.warnIfNotLibrary("arduinopio:Timer1Conflict", ...
                "Continuous Servo Write uses Timer1. Avoid PWM on pins 9 and 10 and Input Capture on pin 8.");
        end

        function setupImpl(obj)
        %SETUPIMPL - Attach the continuous servo via arduinopioServoSetup under RTW.
        %   Under coder.target("Rtw"), includes arduinopio_servo.h and calls
        %   arduinopioServoSetup(uint8(obj.Pin)). Host simulation is a no-op.
        %
        %   Syntax:
        %       setupImpl(obj)
        %
        %   Inputs:
        %       obj - ContinuousServoWrite system object.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       % Invoked once before stepping during codegen.
        %
        %   See also: CONTINUOUSSERVOWRITE, STEPIMPL
            if coder.target("Rtw")
                coder.cinclude("arduinopio_servo.h");
                coder.ceval("arduinopioServoSetup", uint8(obj.Pin));
            end
        end

        function stepImpl(obj, u)
        %STEPIMPL - Write clamped servo speed with arduinopioServoWriteSpeed under RTW.
        %   Under coder.target("Rtw"), clamps double(u) to [-100, 100] as int8, then cevals
        %   arduinopioServoWriteSpeed(uint8(obj.Pin), speed). Host simulation is a no-op.
        %
        %   Syntax:
        %       stepImpl(obj, u)
        %
        %   Inputs:
        %       obj - ContinuousServoWrite system object.
        %       u - Speed command; clamped to -100..100 before write.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       % Invoked by the System object step method during codegen.
        %
        %   See also: CONTINUOUSSERVOWRITE, SETUPIMPL
            if coder.target("Rtw")
                speed = int8(min(max(double(u), -100), 100));
                coder.ceval("arduinopioServoWriteSpeed", uint8(obj.Pin), speed);
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
        %   See also: CONTINUOUSSERVOWRITE, GETNUMOUTPUTSIMPL
            num = 1;
        end

        function num = getNumOutputsImpl(~)
        %GETNUMOUTPUTSIMPL - Report zero System object step outputs.
        %
        %   Syntax:
        %       num = getNumOutputsImpl(~)
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
        %   See also: CONTINUOUSSERVOWRITE, GETNUMINPUTSIMPL
            num = 0;
        end

        function icon = getIconImpl(obj)
        %GETICONIMPL - Build the block icon string with the configured pin.
        %   Calls arduinopio.iconWithPin("Continuous Servo Write", obj.Pin).
        %
        %   Syntax:
        %       icon = getIconImpl(obj)
        %
        %   Inputs:
        %       obj - ContinuousServoWrite system object.
        %
        %   Outputs:
        %       icon - Icon text from iconWithPin.
        %
        %   Example:
        %       % Used by Simulink to label the MATLAB System block.
        %
        %   See also: CONTINUOUSSERVOWRITE, ICONWITHPIN
            icon = arduinopio.iconWithPin("Continuous Servo Write", obj.Pin);
        end

        function sts = getSampleTimeImpl(obj)
        %GETSAMPLETIMEIMPL - Inherited sample time when SampleTime is -1, else discrete.
        %   Uses createSampleTime Type="Inherited" or Type="Discrete" with obj.SampleTime.
        %
        %   Syntax:
        %       sts = getSampleTimeImpl(obj)
        %
        %   Inputs:
        %       obj - ContinuousServoWrite system object.
        %
        %   Outputs:
        %       sts - Sample time specification object.
        %
        %   Example:
        %       % Queried by Simulink for sample-time propagation.
        %
        %   See also: CONTINUOUSSERVOWRITE, CREATESAMPLETIME
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
        %       name - "Arduino PIO Continuous Servo Write".
        %
        %   Example:
        %       % Used by coder.ExternalDependency tooling.
        %
        %   See also: CONTINUOUSSERVOWRITE, ISSUPPORTEDCONTEXT
            name = "Arduino PIO Continuous Servo Write";
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
        %   See also: CONTINUOUSSERVOWRITE, UPDATEBUILDINFO
            tf = context.isCodeGenTarget("rtw");
        end

        function updateBuildInfo(buildInfo, context)
        %UPDATEBUILDINFO - Add servo driver source and Servo library dependency.
        %   Calls updateDriverBuildInfo(buildInfo, context, "arduinopio_servo.cpp", "Servo").
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
        %   See also: CONTINUOUSSERVOWRITE, UPDATEDRIVERBUILDINFO
            arduinopio.updateDriverBuildInfo(buildInfo, context, "arduinopio_servo.cpp", "Servo");
        end
    end
end
