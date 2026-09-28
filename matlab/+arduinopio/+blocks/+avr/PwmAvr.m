classdef (Sealed) PwmAvr < matlab.System & coder.ExternalDependency
    %PWMAVR - PWM with AVR timer mode and prescaler control.
    %   Sealed matlab.System plus coder.ExternalDependency for Advanced AVR PWM.
    %   Nontunable Pin defaults to 5; PrescalerSelect defaults to 3 (member of
    %   1:5 mapping to /1,/8,/64,/256,/1024 per getHeaderImpl); FastPwm defaults
    %   to true; SampleTime defaults to -1 (inherited). validatePropertiesImpl
    %   validates kind "pwm" and warns via arduinopio.warnTimerConflict.
    %   On RTW, setupImpl maps pins 5/6 to timer 0, 9/10 to timer 1, else timer
    %   2, includes arduinopio_pwm_avr.h, and calls arduinopioPwmAvrSetup.
    %   stepImpl clamps duty to [0, 255] as uint8 and calls arduinopioPwmAvrWrite.
    %   Host performs no I/O. updateBuildInfo adds arduinopio_pwm_avr.cpp.
    %
    %   Syntax:
    %       obj = arduinopio.blocks.avr.PwmAvr
    %       obj = arduinopio.blocks.avr.PwmAvr(Name=value)
    %
    %   Inputs:
    %       Pin             - (1,1) nonnegative integer PWM pin. Default: 5.
    %       PrescalerSelect - (1,1) integer in 1:5. Default: 3.
    %       FastPwm         - (1,1) logical fast-PWM mode. Default: true.
    %       SampleTime      - (1,1) double. Default: -1 (inherited).
    %       u (step)        - Duty cycle; clamped to [0, 255].
    %
    %   Outputs:
    %       obj - PwmAvr System object. stepImpl has one duty input and no outputs.
    %
    %   Example:
    %       obj = arduinopio.blocks.avr.PwmAvr(Pin=5, PrescalerSelect=3);
    %
    %   Other m-files required: arduinopio.validatePin, arduinopio.warnTimerConflict,
    %       arduinopio.iconWithPin, arduinopio.updateDriverBuildInfo
    %   Subfunctions: none
    %   MAT-files required: none
    %
    %   See also: PWM, ANALOGINPUTAVR, HARDWAREINTERRUPTAVR

    %   Author: Frey, Jed
    %   28-Sep-2026; Last revision: 28-Sep-2026

    properties (Nontunable)
        Pin (1,1) {mustBeInteger, mustBeNonnegative} = 5
        PrescalerSelect (1,1) {mustBeInteger, mustBeMember(PrescalerSelect, 1:5)} = 3
        FastPwm (1,1) logical = true
        SampleTime (1,1) double = -1
    end

    methods
        function obj = PwmAvr(varargin)
        %PWMAVR - Construct a PwmAvr System object from name-value pairs.
        %   Calls coder.allowpcode("plain") and setProperties for nontunable
        %   pin, prescaler, FastPwm, and sample-time properties.
        %
        %   Syntax:
        %       obj = PwmAvr()
        %       obj = PwmAvr(Name=value)
        %
        %   Inputs:
        %       varargin - Optional name-value pairs for nontunable properties.
        %
        %   Outputs:
        %       obj - Constructed PwmAvr instance.
        %
        %   Example:
        %       obj = arduinopio.blocks.avr.PwmAvr(FastPwm=true);
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
        %   arduinopio.warnTimerConflict(obj.Pin, "PWM AVR").
        %
        %   Syntax:
        %       validatePropertiesImpl(obj)
        %
        %   Inputs:
        %       obj - PwmAvr System object.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       % Invoked by the System object framework during setup.
        %
        %   See also: VALIDATEPIN, WARNTIMERCONFLICT

            arduinopio.validatePin(obj.Pin, "pwm");
            arduinopio.warnTimerConflict(obj.Pin, "PWM AVR");
        end

        function setupImpl(obj)
        %SETUPIMPL - Configure AVR PWM timer, prescaler, and mode on RTW.
        %   Selects timerId 0 for pins 5/6, 1 for 9/10, else 2. Includes
        %   arduinopio_pwm_avr.h and calls arduinopioPwmAvrSetup(Pin, timerId,
        %   PrescalerSelect, FastPwm). No host setup.
        %
        %   Syntax:
        %       setupImpl(obj)
        %
        %   Inputs:
        %       obj - PwmAvr System object.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       % Invoked once before stepImpl during simulation or codegen.
        %
        %   See also: STEPIMPL, ARDUINOPIOPWMAVRSETUP

            if coder.target("Rtw")
                timerId = uint8(2);
                if (obj.Pin == 5) || (obj.Pin == 6)
                    timerId = uint8(0);
                elseif (obj.Pin == 9) || (obj.Pin == 10)
                    timerId = uint8(1);
                end
                coder.cinclude("arduinopio_pwm_avr.h");
                coder.ceval("arduinopioPwmAvrSetup", uint8(obj.Pin), timerId, ...
                    uint8(obj.PrescalerSelect), uint8(obj.FastPwm));
            end
        end

        function stepImpl(obj, u)
        %STEPIMPL - Write clamped PWM duty cycle 0-255 via AVR driver on RTW.
        %   Clamps double(u) to [0, 255] as uint8 and calls
        %   arduinopioPwmAvrWrite(Pin, duty). Host performs no write.
        %
        %   Syntax:
        %       stepImpl(obj, u)
        %
        %   Inputs:
        %       obj - PwmAvr System object.
        %       u   - Duty cycle input; values outside 0-255 are clamped.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       % Driven each sample by the Simulink System block.
        %
        %   See also: SETUPIMPL, ARDUINOPIOPWMAVRWRITE

            if coder.target("Rtw")
                duty = uint8(min(max(double(u), 0), 255));
                coder.ceval("arduinopioPwmAvrWrite", uint8(obj.Pin), duty);
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
        %GETNUMOUTPUTSIMPL - Report zero output ports for AVR PWM write.
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
        %GETICONIMPL - Build the block icon including the PWM AVR pin.
        %   Returns arduinopio.iconWithPin("PWM AVR", obj.Pin).
        %
        %   Syntax:
        %       icon = getIconImpl(obj)
        %
        %   Inputs:
        %       obj - PwmAvr System object.
        %
        %   Outputs:
        %       icon - Icon line(s) for the Simulink block mask.
        %
        %   Example:
        %       % Queried when drawing the System block icon.
        %
        %   See also: ICONWITHPIN

            icon = arduinopio.iconWithPin("PWM AVR", obj.Pin);
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
        %       obj - PwmAvr System object.
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
        %GETDESCRIPTIVENAME - Return the codegen display name for PWM AVR.
        %   Returns the string "Arduino PIO PWM AVR".
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

            name = "Arduino PIO PWM AVR";
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
        %UPDATEBUILDINFO - Register arduinopio_pwm_avr.cpp for codegen.
        %   Calls arduinopio.updateDriverBuildInfo with source
        %   "arduinopio_pwm_avr.cpp".
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

            arduinopio.updateDriverBuildInfo(buildInfo, context, "arduinopio_pwm_avr.cpp");
        end
    end

    methods (Static, Access = protected)
        function header = getHeaderImpl()
        %GETHEADERIMPL - System block dialog header for PWM AVR options.
        %   Returns matlab.system.display.Header for
        %   "arduinopio.blocks.avr.PwmAvr" titled "PWM AVR" documenting
        %   PrescalerSelect 1-5 and Timer1 sharing on pins 9 and 10.
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
                "arduinopio.blocks.avr.PwmAvr", ...
                Title="PWM AVR", ...
                Text="PrescalerSelect 1-5 maps to /1,/8,/64,/256,/1024. Pins 9 and 10 share Timer1 with Servo and Input Capture.");
        end
    end
end
