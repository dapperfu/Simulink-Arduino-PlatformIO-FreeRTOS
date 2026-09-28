classdef (Sealed) HardwareInterruptAvr < matlab.System & coder.ExternalDependency
    %HARDWAREINTERRUPTAVR - Detect a pending AVR peripheral interrupt event.
    %   Sealed matlab.System plus coder.ExternalDependency. Output is true when
    %   an event is pending. Nontunable SourceId defaults to 0 (member of
    %   {0,1,2,3}: Timer1 overflow, Timer1 compare A, Timer2 overflow, ADC
    %   complete per getHeaderImpl). SampleTime defaults to -1 (inherited).
    %   On RTW, setupImpl includes arduinopio_hwint_avr.h and calls
    %   arduinopioHwIntAvrSetup(SourceId). stepImpl on RTW takes a pending flag
    %   via arduinopioHwIntAvrTake; on host, y = logical(simIrq) from the input.
    %   updateBuildInfo adds arduinopio_hwint_avr.cpp. Timer0 and USART RX stay
    %   with the Arduino core.
    %
    %   Syntax:
    %       obj = arduinopio.blocks.avr.HardwareInterruptAvr
    %       obj = arduinopio.blocks.avr.HardwareInterruptAvr(Name=value)
    %
    %   Inputs:
    %       SourceId   - (1,1) integer in {0,1,2,3}. Default: 0.
    %       SampleTime - (1,1) double. Default: -1 (inherited).
    %       simIrq     - stepImpl host-sim input; forwarded as logical output.
    %
    %   Outputs:
    %       obj - HardwareInterruptAvr System object.
    %       y   - stepImpl output: logical true when an interrupt is pending.
    %
    %   Example:
    %       obj = arduinopio.blocks.avr.HardwareInterruptAvr(SourceId=0);
    %
    %   Other m-files required: arduinopio.updateDriverBuildInfo
    %   Subfunctions: none
    %   MAT-files required: none
    %
    %   See also: PWMAVR, ANALOGINPUTAVR

    %   Author: Frey, Jed
    %   28-Sep-2026; Last revision: 28-Sep-2026

    properties (Nontunable)
        SourceId (1,1) {mustBeInteger, mustBeMember(SourceId, [0, 1, 2, 3])} = 0
        SampleTime (1,1) double = -1
    end

    methods
        function obj = HardwareInterruptAvr(varargin)
        %HARDWAREINTERRUPTAVR - Construct a HardwareInterruptAvr System object.
        %   Calls coder.allowpcode("plain") and setProperties for nontunable
        %   SourceId and SampleTime.
        %
        %   Syntax:
        %       obj = HardwareInterruptAvr()
        %       obj = HardwareInterruptAvr(Name=value)
        %
        %   Inputs:
        %       varargin - Optional name-value pairs for nontunable properties.
        %
        %   Outputs:
        %       obj - Constructed HardwareInterruptAvr instance.
        %
        %   Example:
        %       obj = arduinopio.blocks.avr.HardwareInterruptAvr(SourceId=3);
        %
        %   See also: SETUPIMPL, STEPIMPL

            coder.allowpcode("plain");
            setProperties(obj, nargin, varargin{:});
        end
    end

    methods (Access = protected)
        function setupImpl(obj)
        %SETUPIMPL - Enable the selected AVR hardware interrupt source on RTW.
        %   When coder.target is "Rtw", includes arduinopio_hwint_avr.h and
        %   calls arduinopioHwIntAvrSetup(uint8(SourceId)). No host setup.
        %
        %   Syntax:
        %       setupImpl(obj)
        %
        %   Inputs:
        %       obj - HardwareInterruptAvr System object.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       % Invoked once before stepImpl during simulation or codegen.
        %
        %   See also: STEPIMPL, ARDUINOPIOHWINTAVRSETUP

            if coder.target("Rtw")
                coder.cinclude("arduinopio_hwint_avr.h");
                coder.ceval("arduinopioHwIntAvrSetup", uint8(obj.SourceId));
            end
        end

        function y = stepImpl(obj, simIrq)
        %STEPIMPL - Report whether a hardware interrupt event is pending.
        %   On RTW, calls arduinopioHwIntAvrTake(SourceId) and sets
        %   y = (pending ~= 0). On host, y = logical(simIrq).
        %
        %   Syntax:
        %       y = stepImpl(obj, simIrq)
        %
        %   Inputs:
        %       obj    - HardwareInterruptAvr System object.
        %       simIrq - Host-simulation interrupt stimulus (ignored on RTW).
        %
        %   Outputs:
        %       y - Logical true when an interrupt event is pending.
        %
        %   Example:
        %       % Driven each sample by the Simulink System block.
        %
        %   See also: SETUPIMPL, ARDUINOPIOHWINTAVRTAKE

            if coder.target("Rtw")
                pending = uint8(0);
                pending = coder.ceval("arduinopioHwIntAvrTake", uint8(obj.SourceId));
                y = (pending ~= 0);
            else
                y = logical(simIrq);
            end
        end

        function num = getNumInputsImpl(~)
        %GETNUMINPUTSIMPL - Report one input port for host-sim IRQ stimulus.
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
        %GETNUMOUTPUTSIMPL - Report one output port for the pending flag.
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
        %GETOUTPUTSIZEIMPL - Pending-flag output is 1-by-1.
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
        %GETOUTPUTDATATYPEIMPL - Pending-flag output type is logical.
        %   Returns the string "logical".
        %
        %   Syntax:
        %       dt = getOutputDataTypeImpl(obj)
        %
        %   Inputs:
        %       ~ - Unused System object.
        %
        %   Outputs:
        %       dt - Data type name "logical".
        %
        %   Example:
        %       % Queried during model compilation.
        %
        %   See also: GETOUTPUTSIZEIMPL

            dt = "logical";
        end

        function c = isOutputComplexImpl(~)
        %ISOUTPUTCOMPLEXIMPL - Pending-flag output is real-valued.
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
        %ISOUTPUTFIXEDSIZEIMPL - Pending-flag output has fixed size.
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

        function icon = getIconImpl(~)
        %GETICONIMPL - Block icon label for Hardware Interrupt AVR.
        %   Returns the string "Hardware Interrupt AVR".
        %
        %   Syntax:
        %       icon = getIconImpl(obj)
        %
        %   Inputs:
        %       ~ - Unused System object.
        %
        %   Outputs:
        %       icon - Icon text for the Simulink block mask.
        %
        %   Example:
        %       % Queried when drawing the System block icon.
        %
        %   See also: STEPIMPL

            icon = "Hardware Interrupt AVR";
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
        %       obj - HardwareInterruptAvr System object.
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
        %GETDESCRIPTIVENAME - Return the codegen name for Hardware Interrupt AVR.
        %   Returns the string "Arduino PIO Hardware Interrupt AVR".
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

            name = "Arduino PIO Hardware Interrupt AVR";
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
        %UPDATEBUILDINFO - Register arduinopio_hwint_avr.cpp for codegen.
        %   Calls arduinopio.updateDriverBuildInfo with source
        %   "arduinopio_hwint_avr.cpp".
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

            arduinopio.updateDriverBuildInfo(buildInfo, context, "arduinopio_hwint_avr.cpp");
        end
    end

    methods (Static, Access = protected)
        function header = getHeaderImpl()
        %GETHEADERIMPL - System block dialog header for interrupt source IDs.
        %   Returns matlab.system.display.Header for
        %   "arduinopio.blocks.avr.HardwareInterruptAvr" titled
        %   "Hardware Interrupt AVR" listing SourceId meanings and noting
        %   Timer0 and USART RX remain with the Arduino core.
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
                "arduinopio.blocks.avr.HardwareInterruptAvr", ...
                Title="Hardware Interrupt AVR", ...
                Text="0=Timer1 overflow, 1=Timer1 compare A, 2=Timer2 overflow, 3=ADC complete. Timer0 and USART RX stay with the Arduino core.");
        end
    end
end
