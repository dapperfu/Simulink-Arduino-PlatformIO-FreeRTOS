classdef (Sealed) InputCapture < matlab.System & coder.ExternalDependency
    %INPUTCAPTURE - Measure input frequency and duty cycle via AVR capture.
    %   Sealed matlab.System plus coder.ExternalDependency. Uno input capture is
    %   ICP1 on pin 8 (Timer1). Nontunable Pin defaults to 8; SampleTime defaults
    %   to -1 (inherited). validatePropertiesImpl validates kind "capture" and
    %   warns via arduinopio.warnIfNotLibrary that Timer1 conflicts with PWM on
    %   pins 9 and 10 and Servo blocks. On RTW, setupImpl includes
    %   arduinopio_capture.h and calls arduinopioCaptureSetup(Pin). stepImpl
    %   returns single frequencyHz and dutyCycle; on RTW fills them via
    %   arduinopioCaptureRead. Host returns zeros. updateBuildInfo adds
    %   arduinopio_capture.cpp. This System object is the block implementation.
    %
    %   Syntax:
    %       obj = arduinopio.blocks.common.InputCapture
    %       obj = arduinopio.blocks.common.InputCapture(Name=value)
    %
    %   Inputs:
    %       Pin        - (1,1) nonnegative integer capture pin. Default: 8.
    %       SampleTime - (1,1) double. Default: -1 (inherited).
    %
    %   Outputs:
    %       obj         - InputCapture System object.
    %       frequencyHz - stepImpl output 1: measured frequency (single).
    %       dutyCycle   - stepImpl output 2: measured duty cycle (single).
    %
    %   Example:
    %       obj = arduinopio.blocks.common.InputCapture(Pin=8);
    %
    %   Other m-files required: arduinopio.validatePin, arduinopio.warnIfNotLibrary,
    %       arduinopio.iconWithPin, arduinopio.updateDriverBuildInfo
    %   Subfunctions: none
    %   MAT-files required: none
    %
    %   See also: PWM, STANDARDSERVOWRITE, WARNTIMERCONFLICT

    %   Author: Frey, Jed
    %   28-Sep-2026; Last revision: 28-Sep-2026

    properties (Nontunable)
        Pin (1,1) {mustBeInteger, mustBeNonnegative} = 8
        SampleTime (1,1) double = -1
    end

    methods
        function obj = InputCapture(varargin)
        %INPUTCAPTURE - Construct an InputCapture System object.
        %   Calls coder.allowpcode("plain") and setProperties for nontunable
        %   Pin and SampleTime.
        %
        %   Syntax:
        %       obj = InputCapture()
        %       obj = InputCapture(Name=value)
        %
        %   Inputs:
        %       varargin - Optional name-value pairs for nontunable properties.
        %
        %   Outputs:
        %       obj - Constructed InputCapture instance.
        %
        %   Example:
        %       obj = arduinopio.blocks.common.InputCapture(Pin=8);
        %
        %   See also: SETUPIMPL, STEPIMPL

            coder.allowpcode("plain");
            setProperties(obj, nargin, varargin{:});
        end
    end

    methods (Access = protected)
        function validatePropertiesImpl(obj)
        %VALIDATEPROPERTIESIMPL - Validate capture pin and warn on Timer1 use.
        %   Calls arduinopio.validatePin(obj.Pin, "capture") and
        %   arduinopio.warnIfNotLibrary with id "arduinopio:Timer1Conflict"
        %   describing Timer1 conflicts with PWM pins 9/10 and Servo.
        %
        %   Syntax:
        %       validatePropertiesImpl(obj)
        %
        %   Inputs:
        %       obj - InputCapture System object.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       % Invoked by the System object framework during setup.
        %
        %   See also: VALIDATEPIN, WARNIFNOTLIBRARY

            arduinopio.validatePin(obj.Pin, "capture");
            arduinopio.warnIfNotLibrary("arduinopio:Timer1Conflict", ...
                "Input Capture on pin " + string(obj.Pin) + ...
                " uses Timer1. Avoid PWM on pins 9 and 10 and Servo blocks.");
        end

        function setupImpl(obj)
        %SETUPIMPL - Configure hardware input capture on RTW.
        %   When coder.target is "Rtw", includes arduinopio_capture.h and calls
        %   arduinopioCaptureSetup with uint8(obj.Pin). No host setup.
        %
        %   Syntax:
        %       setupImpl(obj)
        %
        %   Inputs:
        %       obj - InputCapture System object.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       % Invoked once before stepImpl during simulation or codegen.
        %
        %   See also: STEPIMPL, ARDUINOPIOCAPTURESETUP

            if coder.target("Rtw")
                coder.cinclude("arduinopio_capture.h");
                coder.ceval("arduinopioCaptureSetup", uint8(obj.Pin));
            end
        end

        function [frequencyHz, dutyCycle] = stepImpl(~)
        %STEPIMPL - Read measured frequency and duty cycle from capture.
        %   Initializes both outputs to single(0). On RTW calls
        %   arduinopioCaptureRead with coder.wref for each. Host returns zeros.
        %
        %   Syntax:
        %       [frequencyHz, dutyCycle] = stepImpl(obj)
        %
        %   Inputs:
        %       ~ - Unused System object.
        %
        %   Outputs:
        %       frequencyHz - Measured frequency in hertz (single).
        %       dutyCycle   - Measured duty cycle (single).
        %
        %   Example:
        %       % Driven each sample by the Simulink System block.
        %
        %   See also: SETUPIMPL, ARDUINOPIOCAPTUREREAD

            frequencyHz = single(0);
            dutyCycle = single(0);
            if coder.target("Rtw")
                coder.ceval("arduinopioCaptureRead", coder.wref(frequencyHz), coder.wref(dutyCycle));
            end
        end

        function num = getNumInputsImpl(~)
        %GETNUMINPUTSIMPL - Report zero input ports for input capture.
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
        %GETNUMOUTPUTSIMPL - Report two outputs: frequency and duty cycle.
        %   Returns a fixed output count of 2.
        %
        %   Syntax:
        %       num = getNumOutputsImpl(obj)
        %
        %   Inputs:
        %       ~ - Unused System object.
        %
        %   Outputs:
        %       num - Number of outputs (2).
        %
        %   Example:
        %       % Queried by the System object framework.
        %
        %   See also: GETNUMINPUTSIMPL

            num = 2;
        end

        function [sz1, sz2] = getOutputSizeImpl(~)
        %GETOUTPUTSIZEIMPL - Both capture outputs are 1-by-1.
        %   Returns sz1 = [1, 1] and sz2 = [1, 1].
        %
        %   Syntax:
        %       [sz1, sz2] = getOutputSizeImpl(obj)
        %
        %   Inputs:
        %       ~ - Unused System object.
        %
        %   Outputs:
        %       sz1 - Size of frequencyHz ([1, 1]).
        %       sz2 - Size of dutyCycle ([1, 1]).
        %
        %   Example:
        %       % Queried during model compilation.
        %
        %   See also: GETOUTPUTDATATYPEIMPL

            sz1 = [1, 1];
            sz2 = [1, 1];
        end

        function [dt1, dt2] = getOutputDataTypeImpl(~)
        %GETOUTPUTDATATYPEIMPL - Both capture outputs are single.
        %   Returns dt1 = "single" and dt2 = "single".
        %
        %   Syntax:
        %       [dt1, dt2] = getOutputDataTypeImpl(obj)
        %
        %   Inputs:
        %       ~ - Unused System object.
        %
        %   Outputs:
        %       dt1 - Data type of frequencyHz ("single").
        %       dt2 - Data type of dutyCycle ("single").
        %
        %   Example:
        %       % Queried during model compilation.
        %
        %   See also: GETOUTPUTSIZEIMPL

            dt1 = "single";
            dt2 = "single";
        end

        function [c1, c2] = isOutputComplexImpl(~)
        %ISOUTPUTCOMPLEXIMPL - Both capture outputs are real-valued.
        %   Returns c1 = false and c2 = false.
        %
        %   Syntax:
        %       [c1, c2] = isOutputComplexImpl(obj)
        %
        %   Inputs:
        %       ~ - Unused System object.
        %
        %   Outputs:
        %       c1 - Complexity of frequencyHz (false).
        %       c2 - Complexity of dutyCycle (false).
        %
        %   Example:
        %       % Queried during model compilation.
        %
        %   See also: ISOUTPUTFIXEDSIZEIMPL

            c1 = false;
            c2 = false;
        end

        function [f1, f2] = isOutputFixedSizeImpl(~)
        %ISOUTPUTFIXEDSIZEIMPL - Both capture outputs have fixed size.
        %   Returns f1 = true and f2 = true.
        %
        %   Syntax:
        %       [f1, f2] = isOutputFixedSizeImpl(obj)
        %
        %   Inputs:
        %       ~ - Unused System object.
        %
        %   Outputs:
        %       f1 - Fixed-size flag for frequencyHz (true).
        %       f2 - Fixed-size flag for dutyCycle (true).
        %
        %   Example:
        %       % Queried during model compilation.
        %
        %   See also: ISOUTPUTCOMPLEXIMPL

            f1 = true;
            f2 = true;
        end

        function icon = getIconImpl(obj)
        %GETICONIMPL - Build the block icon including the capture pin.
        %   Returns arduinopio.iconWithPin("Input Capture", obj.Pin).
        %
        %   Syntax:
        %       icon = getIconImpl(obj)
        %
        %   Inputs:
        %       obj - InputCapture System object.
        %
        %   Outputs:
        %       icon - Icon line(s) for the Simulink block mask.
        %
        %   Example:
        %       % Queried when drawing the System block icon.
        %
        %   See also: ICONWITHPIN

            icon = arduinopio.iconWithPin("Input Capture", obj.Pin);
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
        %       obj - InputCapture System object.
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
        %GETDESCRIPTIVENAME - Return the codegen display name for Input Capture.
        %   Returns the string "Arduino PIO Input Capture".
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

            name = "Arduino PIO Input Capture";
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
        %UPDATEBUILDINFO - Register arduinopio_capture.cpp for codegen.
        %   Calls arduinopio.updateDriverBuildInfo with source
        %   "arduinopio_capture.cpp".
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

            arduinopio.updateDriverBuildInfo(buildInfo, context, "arduinopio_capture.cpp");
        end
    end
end
