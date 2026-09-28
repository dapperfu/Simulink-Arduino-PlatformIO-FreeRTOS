classdef (Sealed) StandardServoRead < matlab.System & coder.ExternalDependency
    %STANDARDSERVOREAD - Read the last commanded standard servo angle in degrees.
    %   Sealed matlab.System plus coder.ExternalDependency. Nontunable Pin
    %   defaults to 9; SampleTime defaults to -1 (inherited).
    %   validatePropertiesImpl validates kind "digital". On RTW, setupImpl
    %   includes arduinopio_servo.h and calls arduinopioServoSetup(Pin).
    %   stepImpl returns uint8; on RTW the value comes from
    %   arduinopioServoReadAngle, on host it remains 0. updateBuildInfo adds
    %   arduinopio_servo.cpp and the Servo library dependency. This System
    %   object is the block implementation.
    %
    %   Syntax:
    %       obj = arduinopio.blocks.common.StandardServoRead
    %       obj = arduinopio.blocks.common.StandardServoRead(Name=value)
    %
    %   Inputs:
    %       Pin        - (1,1) nonnegative integer servo pin. Default: 9.
    %       SampleTime - (1,1) double. Default: -1 (inherited).
    %
    %   Outputs:
    %       obj - StandardServoRead System object.
    %       y   - stepImpl output: last commanded angle in degrees (uint8).
    %
    %   Example:
    %       obj = arduinopio.blocks.common.StandardServoRead(Pin=9);
    %
    %   Other m-files required: arduinopio.validatePin, arduinopio.iconWithPin,
    %       arduinopio.updateDriverBuildInfo
    %   Subfunctions: none
    %   MAT-files required: none
    %
    %   See also: STANDARDSERVOWRITE, CONTINUOUSSERVOWRITE

    %   Author: Frey, Jed
    %   28-Sep-2026; Last revision: 28-Sep-2026

    properties (Nontunable)
        Pin (1,1) {mustBeInteger, mustBeNonnegative} = 9
        SampleTime (1,1) double = -1
    end

    methods
        function obj = StandardServoRead(varargin)
        %STANDARDSERVOREAD - Construct a StandardServoRead System object.
        %   Calls coder.allowpcode("plain") and setProperties for nontunable
        %   Pin and SampleTime.
        %
        %   Syntax:
        %       obj = StandardServoRead()
        %       obj = StandardServoRead(Name=value)
        %
        %   Inputs:
        %       varargin - Optional name-value pairs for nontunable properties.
        %
        %   Outputs:
        %       obj - Constructed StandardServoRead instance.
        %
        %   Example:
        %       obj = arduinopio.blocks.common.StandardServoRead(Pin=9);
        %
        %   See also: SETUPIMPL, STEPIMPL

            coder.allowpcode("plain");
            setProperties(obj, nargin, varargin{:});
        end
    end

    methods (Access = protected)
        function validatePropertiesImpl(obj)
        %VALIDATEPROPERTIESIMPL - Validate the servo pin as digital I/O.
        %   Calls arduinopio.validatePin(obj.Pin, "digital").
        %
        %   Syntax:
        %       validatePropertiesImpl(obj)
        %
        %   Inputs:
        %       obj - StandardServoRead System object.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       % Invoked by the System object framework during setup.
        %
        %   See also: VALIDATEPIN

            arduinopio.validatePin(obj.Pin, "digital");
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
        %       obj - StandardServoRead System object.
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

        function y = stepImpl(obj)
        %STEPIMPL - Read the last commanded servo angle in degrees.
        %   Initializes y to uint8(0). On RTW assigns y from
        %   arduinopioServoReadAngle(Pin). Host returns 0.
        %
        %   Syntax:
        %       y = stepImpl(obj)
        %
        %   Inputs:
        %       obj - StandardServoRead System object.
        %
        %   Outputs:
        %       y - Last commanded angle in degrees (uint8); 0 on host.
        %
        %   Example:
        %       % Driven each sample by the Simulink System block.
        %
        %   See also: SETUPIMPL, ARDUINOPIOSERVOREADANGLE

            y = uint8(0);
            if coder.target("Rtw")
                y = coder.ceval("arduinopioServoReadAngle", uint8(obj.Pin));
            end
        end

        function num = getNumInputsImpl(~)
        %GETNUMINPUTSIMPL - Report zero input ports for servo read.
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
        %GETNUMOUTPUTSIMPL - Report one output port for servo angle.
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
        %GETOUTPUTSIZEIMPL - Servo angle output is 1-by-1.
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
        %GETOUTPUTDATATYPEIMPL - Servo angle output type is uint8.
        %   Returns the string "uint8".
        %
        %   Syntax:
        %       dt = getOutputDataTypeImpl(obj)
        %
        %   Inputs:
        %       ~ - Unused System object.
        %
        %   Outputs:
        %       dt - Data type name "uint8".
        %
        %   Example:
        %       % Queried during model compilation.
        %
        %   See also: GETOUTPUTSIZEIMPL

            dt = "uint8";
        end

        function c = isOutputComplexImpl(~)
        %ISOUTPUTCOMPLEXIMPL - Servo angle output is real-valued.
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
        %ISOUTPUTFIXEDSIZEIMPL - Servo angle output has fixed size.
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
        %GETICONIMPL - Build the block icon including the servo pin.
        %   Returns arduinopio.iconWithPin("Standard Servo Read", obj.Pin).
        %
        %   Syntax:
        %       icon = getIconImpl(obj)
        %
        %   Inputs:
        %       obj - StandardServoRead System object.
        %
        %   Outputs:
        %       icon - Icon line(s) for the Simulink block mask.
        %
        %   Example:
        %       % Queried when drawing the System block icon.
        %
        %   See also: ICONWITHPIN

            icon = arduinopio.iconWithPin("Standard Servo Read", obj.Pin);
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
        %       obj - StandardServoRead System object.
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
        %GETDESCRIPTIVENAME - Return the codegen name for Standard Servo Read.
        %   Returns the string "Arduino PIO Standard Servo Read".
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

            name = "Arduino PIO Standard Servo Read";
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
