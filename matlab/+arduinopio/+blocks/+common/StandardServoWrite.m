classdef (Sealed) StandardServoWrite < matlab.System & coder.ExternalDependency
    %STANDARDSERVOWRITE - Set a standard servo shaft angle in degrees.
    %   Sealed matlab.System plus coder.ExternalDependency. Uses Timer1 on Uno.
    %   Nontunable Pin defaults to 9; SampleTime defaults to -1 (inherited).
    %   validatePropertiesImpl validates kind "digital" and warns via
    %   arduinopio.warnIfNotLibrary that Timer1 conflicts with PWM on pins 9
    %   and 10 and Input Capture on pin 8. On RTW, setupImpl includes
    %   arduinopio_servo.h and calls arduinopioServoSetup(Pin). stepImpl clamps
    %   the angle to [0, 180] as uint8 and calls arduinopioServoWriteAngle.
    %   Host performs no write. updateBuildInfo adds arduinopio_servo.cpp and
    %   the Servo library. This System object is the block implementation.
    %
    %   Syntax:
    %       obj = arduinopio.blocks.common.StandardServoWrite
    %       obj = arduinopio.blocks.common.StandardServoWrite(Name=value)
    %
    %   Inputs:
    %       Pin        - (1,1) nonnegative integer servo pin. Default: 9.
    %       SampleTime - (1,1) double. Default: -1 (inherited).
    %       u (step)   - Desired angle in degrees; clamped to [0, 180].
    %
    %   Outputs:
    %       obj - StandardServoWrite System object. stepImpl has one input, no outputs.
    %
    %   Example:
    %       obj = arduinopio.blocks.common.StandardServoWrite(Pin=9);
    %
    %   Other m-files required: arduinopio.validatePin, arduinopio.warnIfNotLibrary,
    %       arduinopio.iconWithPin, arduinopio.updateDriverBuildInfo
    %   Subfunctions: none
    %   MAT-files required: none
    %
    %   See also: STANDARDSERVOREAD, INPUTCAPTURE, PWM

    %   Author: Frey, Jed
    %   28-Sep-2026; Last revision: 28-Sep-2026

    properties (Nontunable)
        Pin (1,1) {mustBeInteger, mustBeNonnegative} = 9
        SampleTime (1,1) double = -1
    end

    methods
        function obj = StandardServoWrite(varargin)
        %STANDARDSERVOWRITE - Construct a StandardServoWrite System object.
        %   Calls coder.allowpcode("plain") and setProperties for nontunable
        %   Pin and SampleTime.
        %
        %   Syntax:
        %       obj = StandardServoWrite()
        %       obj = StandardServoWrite(Name=value)
        %
        %   Inputs:
        %       varargin - Optional name-value pairs for nontunable properties.
        %
        %   Outputs:
        %       obj - Constructed StandardServoWrite instance.
        %
        %   Example:
        %       obj = arduinopio.blocks.common.StandardServoWrite(Pin=9);
        %
        %   See also: SETUPIMPL, STEPIMPL

            coder.allowpcode("plain");
            setProperties(obj, nargin, varargin{:});
        end
    end

    methods (Access = protected)
        function validatePropertiesImpl(obj)
        %VALIDATEPROPERTIESIMPL - Validate pin and warn on Timer1 conflicts.
        %   Calls arduinopio.validatePin(obj.Pin, "digital") and
        %   arduinopio.warnIfNotLibrary with id "arduinopio:Timer1Conflict"
        %   about PWM pins 9/10 and Input Capture on pin 8.
        %
        %   Syntax:
        %       validatePropertiesImpl(obj)
        %
        %   Inputs:
        %       obj - StandardServoWrite System object.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       % Invoked by the System object framework during setup.
        %
        %   See also: VALIDATEPIN, WARNIFNOTLIBRARY

            arduinopio.validatePin(obj.Pin, "digital");
            arduinopio.warnIfNotLibrary("arduinopio:Timer1Conflict", ...
                "Standard Servo Write uses Timer1. Avoid PWM on pins 9 and 10 and Input Capture on pin 8.");
        end

        function setupImpl(obj)
        %SETUPIMPL - Attach the standard servo on the configured pin on RTW.
        %   When coder.target is "Rtw", includes arduinopio_servo.h and calls
        %   arduinopioServoSetup(uint8(obj.Pin)). No host setup.
        %
        %   Syntax:
        %       setupImpl(obj)
        %
        %   Inputs:
        %       obj - StandardServoWrite System object.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       % Invoked once before stepImpl during simulation or codegen.
        %
        %   See also: STEPIMPL, ARDUINOPIOSERVOSETUP

            if coder.target("Rtw")
                coder.cinclude("arduinopio_servo.h");
                coder.ceval("arduinopioServoSetup", uint8(obj.Pin));
            end
        end

        function stepImpl(obj, u)
        %STEPIMPL - Write a clamped 0-180 degree angle to the servo on RTW.
        %   Clamps double(u) to [0, 180] as uint8 and calls
        %   arduinopioServoWriteAngle(Pin, angleDeg). Host performs no write.
        %
        %   Syntax:
        %       stepImpl(obj, u)
        %
        %   Inputs:
        %       obj - StandardServoWrite System object.
        %       u   - Desired angle in degrees; values outside 0-180 are clamped.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       % Driven each sample by the Simulink System block.
        %
        %   See also: SETUPIMPL, ARDUINOPIOSERVOWRITEANGLE

            if coder.target("Rtw")
                angleDeg = uint8(min(max(double(u), 0), 180));
                coder.ceval("arduinopioServoWriteAngle", uint8(obj.Pin), angleDeg);
            end
        end

        function num = getNumInputsImpl(~)
        %GETNUMINPUTSIMPL - Report one input port for the servo angle.
        %   Returns a fixed input count of 1.
        %
        %   Syntax:
        %       num = getNumInputsImpl(obj)
        %
        %   Inputs:
        %       ~ - Unused System object.
        %
        %   Outputs:
        %       num - Number of inputs (1).
        %
        %   Example:
        %       % Queried by the System object framework.
        %
        %   See also: GETNUMOUTPUTSIMPL

            num = 1;
        end

        function num = getNumOutputsImpl(~)
        %GETNUMOUTPUTSIMPL - Report zero output ports for servo write.
        %   Returns a fixed output count of 0.
        %
        %   Syntax:
        %       num = getNumOutputsImpl(obj)
        %
        %   Inputs:
        %       ~ - Unused System object.
        %
        %   Outputs:
        %       num - Number of outputs (0).
        %
        %   Example:
        %       % Queried by the System object framework.
        %
        %   See also: GETNUMINPUTSIMPL

            num = 0;
        end

        function icon = getIconImpl(obj)
        %GETICONIMPL - Build the block icon including the servo pin.
        %   Returns arduinopio.iconWithPin("Standard Servo Write", obj.Pin).
        %
        %   Syntax:
        %       icon = getIconImpl(obj)
        %
        %   Inputs:
        %       obj - StandardServoWrite System object.
        %
        %   Outputs:
        %       icon - Icon line(s) for the Simulink block mask.
        %
        %   Example:
        %       % Queried when drawing the System block icon.
        %
        %   See also: ICONWITHPIN

            icon = arduinopio.iconWithPin("Standard Servo Write", obj.Pin);
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
        %       obj - StandardServoWrite System object.
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
        %GETDESCRIPTIVENAME - Return the codegen name for Standard Servo Write.
        %   Returns the string "Arduino PIO Standard Servo Write".
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

            name = "Arduino PIO Standard Servo Write";
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
        %UPDATEBUILDINFO - Register servo driver and Servo library for codegen.
        %   Calls arduinopio.updateDriverBuildInfo with
        %   "arduinopio_servo.cpp" and libDep "Servo".
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

            arduinopio.updateDriverBuildInfo(buildInfo, context, "arduinopio_servo.cpp", "Servo");
        end
    end
end
