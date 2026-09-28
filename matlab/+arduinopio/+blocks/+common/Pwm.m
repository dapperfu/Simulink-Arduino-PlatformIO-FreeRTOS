classdef (Sealed) Pwm < matlab.System & coder.ExternalDependency
    %PWM - Generate PWM on an Arduino analog-write pin with duty cycle 0-255.
    %   Sealed matlab.System plus coder.ExternalDependency for Arduino PIO PWM.
    %   Nontunable Pin defaults to 5 and is validated as kind "pwm". SampleTime
    %   defaults to -1 (inherited); otherwise discrete SampleTime is used.
    %   validatePropertiesImpl calls arduinopio.validatePin and
    %   arduinopio.warnTimerConflict for Timer1 sharing. On RTW, setupImpl
    %   includes arduinopio_arduino.h, sets pinMode OUTPUT, and analogWrite 0.
    %   stepImpl clamps the duty input to [0, 255] as int32 and calls analogWrite.
    %   Host simulation performs no hardware I/O. getHeaderImpl documents Uno PWM
    %   pins 3, 5, 6, 9, 10, 11 and Timer1 conflict on pins 9 and 10 with Servo
    %   and Input Capture. This System object is the block implementation.
    %
    %   Syntax:
    %       obj = arduinopio.blocks.common.Pwm
    %       obj = arduinopio.blocks.common.Pwm(Name=value)
    %
    %   Inputs:
    %       Pin        - (1,1) nonnegative integer PWM pin. Default: 5.
    %       SampleTime - (1,1) double. Default: -1 (inherited sample time).
    %
    %   Outputs:
    %       obj - Pwm System object. stepImpl has one duty input and no outputs.
    %
    %   Example:
    %       obj = arduinopio.blocks.common.Pwm(Pin=9);
    %
    %   Other m-files required: arduinopio.validatePin, arduinopio.warnTimerConflict,
    %       arduinopio.iconWithPin, arduinopio.updateDriverBuildInfo
    %   Subfunctions: none
    %   MAT-files required: none
    %
    %   See also: PWMAVR, STANDARDSERVOWRITE, INPUTCAPTURE

    %   Author: Frey, Jed
    %   28-Sep-2026; Last revision: 28-Sep-2026

    properties (Nontunable)
        Pin (1,1) {mustBeInteger, mustBeNonnegative} = 5
        SampleTime (1,1) double = -1
    end

    methods
        function obj = Pwm(varargin)
        %PWM - Construct a PWM System object from optional name-value pairs.
        %   Calls coder.allowpcode("plain") and setProperties for nontunable
        %   Pin and SampleTime.
        %
        %   Syntax:
        %       obj = Pwm()
        %       obj = Pwm(Name=value)
        %
        %   Inputs:
        %       varargin - Optional name-value pairs for nontunable properties.
        %
        %   Outputs:
        %       obj - Constructed Pwm instance.
        %
        %   Example:
        %       obj = arduinopio.blocks.common.Pwm(Pin=5);
        %
        %   See also: SETUPIMPL, STEPIMPL

            coder.allowpcode("plain");
            setProperties(obj, nargin, varargin{:});
        end
    end

    methods (Access = protected)
        function validatePropertiesImpl(obj)
        %VALIDATEPROPERTIESIMPL - Validate PWM pin and warn on Timer1 conflicts.
        %   Calls arduinopio.validatePin(obj.Pin, "pwm") and
        %   arduinopio.warnTimerConflict(obj.Pin, "PWM").
        %
        %   Syntax:
        %       validatePropertiesImpl(obj)
        %
        %   Inputs:
        %       obj - Pwm System object.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       % Invoked by the System object framework during setup.
        %
        %   See also: VALIDATEPIN, WARNTIMERCONFLICT

            arduinopio.validatePin(obj.Pin, "pwm");
            arduinopio.warnTimerConflict(obj.Pin, "PWM");
        end

        function setupImpl(obj)
        %SETUPIMPL - Configure the PWM pin as OUTPUT and clear duty on RTW.
        %   When coder.target is "Rtw", includes arduinopio_arduino.h, calls
        %   pinMode with OUTPUT, then analogWrite with duty 0. No host I/O.
        %
        %   Syntax:
        %       setupImpl(obj)
        %
        %   Inputs:
        %       obj - Pwm System object.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       % Invoked once before stepImpl during simulation or codegen.
        %
        %   See also: STEPIMPL, PINMODE, ANALOGWRITE

            if coder.target("Rtw")
                coder.cinclude("arduinopio_arduino.h");
                coder.ceval("pinMode", uint8(obj.Pin), coder.opaque("uint8_t", "OUTPUT"));
                coder.ceval("analogWrite", uint8(obj.Pin), int32(0));
            end
        end

        function stepImpl(obj, u)
        %STEPIMPL - Write clamped PWM duty cycle 0-255 to the pin on RTW.
        %   Clamps double(u) to [0, 255] as int32, includes arduinopio_arduino.h,
        %   and calls analogWrite. Host simulation performs no hardware write.
        %
        %   Syntax:
        %       stepImpl(obj, u)
        %
        %   Inputs:
        %       obj - Pwm System object.
        %       u   - Duty cycle input; values outside 0-255 are clamped.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       % Driven each sample by the Simulink System block.
        %
        %   See also: SETUPIMPL, ANALOGWRITE

            if coder.target("Rtw")
                duty = int32(min(max(double(u), 0), 255));
                coder.cinclude("arduinopio_arduino.h");
                coder.ceval("analogWrite", uint8(obj.Pin), duty);
            end
        end

        function num = getNumInputsImpl(~)
        %GETNUMINPUTSIMPL - Report one input port for the duty cycle.
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
        %GETNUMOUTPUTSIMPL - Report zero output ports for PWM write.
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

        function flag = isInputSizeMutableImpl(~, ~)
        %ISINPUTSIZEMUTABLEIMPL - Disallow mutable input size for duty cycle.
        %   Always returns false so the duty input size is fixed.
        %
        %   Syntax:
        %       flag = isInputSizeMutableImpl(obj, index)
        %
        %   Inputs:
        %       ~ - Unused System object and input index.
        %
        %   Outputs:
        %       flag - false (input size is not mutable).
        %
        %   Example:
        %       % Queried by the System object framework.
        %
        %   See also: GETNUMINPUTSIMPL

            flag = false;
        end

        function icon = getIconImpl(obj)
        %GETICONIMPL - Build the block icon text including the PWM pin.
        %   Returns arduinopio.iconWithPin("PWM", obj.Pin).
        %
        %   Syntax:
        %       icon = getIconImpl(obj)
        %
        %   Inputs:
        %       obj - Pwm System object.
        %
        %   Outputs:
        %       icon - Icon line(s) for the Simulink block mask.
        %
        %   Example:
        %       % Queried when drawing the System block icon.
        %
        %   See also: ICONWITHPIN

            icon = arduinopio.iconWithPin("PWM", obj.Pin);
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
        %       obj - Pwm System object.
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
        %GETDESCRIPTIVENAME - Return the codegen display name for PWM.
        %   Returns the string "Arduino PIO PWM".
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

            name = "Arduino PIO PWM";
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
        %UPDATEBUILDINFO - Register shared Arduino driver sources for codegen.
        %   Forwards to arduinopio.updateDriverBuildInfo(buildInfo, context) with
        %   no extra source file or library dependency arguments.
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

            arduinopio.updateDriverBuildInfo(buildInfo, context);
        end
    end

    methods (Static, Access = protected)
        function header = getHeaderImpl()
        %GETHEADERIMPL - System block dialog header for PWM pin guidance.
        %   Returns matlab.system.display.Header for
        %   "arduinopio.blocks.common.Pwm" titled "PWM" with text listing Uno
        %   PWM pins 3, 5, 6, 9, 10, 11 and Timer1 sharing on 9 and 10.
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
                "arduinopio.blocks.common.Pwm", ...
                Title="PWM", ...
                Text="Uno PWM pins: 3, 5, 6, 9, 10, 11. Pins 9 and 10 share Timer1 with Servo and Input Capture.");
        end
    end
end
