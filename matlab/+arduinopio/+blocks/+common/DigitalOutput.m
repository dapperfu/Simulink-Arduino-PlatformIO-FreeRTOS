classdef (Sealed) DigitalOutput < matlab.System & coder.ExternalDependency
    %DIGITALOUTPUT - Drive an Arduino digital output pin HIGH or LOW from a step input.
    %   Sealed matlab.System and coder.ExternalDependency for digital-write codegen. The Common
    %   library block uses the Level-2 MATLAB S-function arduinopio_digital_output instead of this
    %   System object. setupImpl calls pinMode(..., OUTPUT); stepImpl calls digitalWrite HIGH or
    %   LOW when coder.target("Rtw") and includes arduinopio_arduino.h. SampleTime -1 inherits;
    %   otherwise discrete. Host simulation does not touch hardware. Nontunable Pin default 13
    %   and SampleTime default -1.
    %
    %   Syntax:
    %       obj = arduinopio.blocks.common.DigitalOutput
    %       obj = arduinopio.blocks.common.DigitalOutput(Pin=13, SampleTime=-1)
    %
    %   Inputs:
    %       Pin - (1,1) nonnegative integer, default 13, validated as "digital" by validatePin.
    %       SampleTime - (1,1) double, default -1 (inherited) or positive discrete period.
    %
    %   Outputs:
    %       obj - Sealed matlab.System object. Step has 1 input and 0 outputs.
    %
    %   Example:
    %       obj = arduinopio.blocks.common.DigitalOutput(Pin=13);
    %
    %   Other m-files required: arduinopio.validatePin, arduinopio.iconWithPin,
    %       arduinopio.updateDriverBuildInfo
    %   Subfunctions: none
    %   MAT-files required: none
    %
    %   See also: DIGITALINPUT, VALIDATEPIN, ICONWITHPIN, UPDATEDRIVERBUILDINFO

    %   Author: Frey, Jed
    %   28-Sep-2026; Last revision: 28-Sep-2026

    properties (Nontunable)
        Pin (1,1) {mustBeInteger, mustBeNonnegative} = 13
        SampleTime (1,1) double = -1
    end

    methods
        function obj = DigitalOutput(varargin)
        %DIGITALOUTPUT - Construct DigitalOutput and apply Name-Value properties.
        %   Enables plain P-code via coder.allowpcode("plain"), then setProperties with varargin.
        %
        %   Syntax:
        %       obj = DigitalOutput(varargin)
        %
        %   Inputs:
        %       varargin - Name-Value pairs for nontunable properties (Pin, SampleTime).
        %
        %   Outputs:
        %       obj - DigitalOutput system object.
        %
        %   Example:
        %       obj = arduinopio.blocks.common.DigitalOutput(Pin=13);
        %
        %   See also: DIGITALOUTPUT, SETPROPERTIES
            coder.allowpcode("plain");
            setProperties(obj, nargin, varargin{:});
        end
    end

    methods (Access = protected)
        function validatePropertiesImpl(obj)
        %VALIDATEPROPERTIESIMPL - Validate Pin as a digital Arduino pin.
        %   Calls arduinopio.validatePin(obj.Pin, "digital").
        %
        %   Syntax:
        %       validatePropertiesImpl(obj)
        %
        %   Inputs:
        %       obj - DigitalOutput system object.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       % Invoked by the System object framework before setup.
        %
        %   See also: DIGITALOUTPUT, VALIDATEPIN
            arduinopio.validatePin(obj.Pin, "digital");
        end

        function setupImpl(obj)
        %SETUPIMPL - Configure the pin as OUTPUT with pinMode when generating code.
        %   Under coder.target("Rtw"), includes arduinopio_arduino.h and calls pinMode with
        %   opaque OUTPUT. Host simulation is a no-op.
        %
        %   Syntax:
        %       setupImpl(obj)
        %
        %   Inputs:
        %       obj - DigitalOutput system object.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       % Invoked once before stepping during codegen.
        %
        %   See also: DIGITALOUTPUT, STEPIMPL
            if coder.target("Rtw")
                coder.cinclude("arduinopio_arduino.h");
                coder.ceval("pinMode", uint8(obj.Pin), coder.opaque("uint8_t", "OUTPUT"));
            end
        end

        function stepImpl(obj, u)
        %STEPIMPL - Write HIGH or LOW with digitalWrite when generating code.
        %   Under coder.target("Rtw"), includes arduinopio_arduino.h; nonzero u writes HIGH,
        %   otherwise LOW. Host simulation is a no-op.
        %
        %   Syntax:
        %       stepImpl(obj, u)
        %
        %   Inputs:
        %       obj - DigitalOutput system object.
        %       u - Logical or numeric; nonzero becomes HIGH.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       % Invoked by the System object step method during codegen.
        %
        %   See also: DIGITALOUTPUT, SETUPIMPL
            if coder.target("Rtw")
                coder.cinclude("arduinopio_arduino.h");
                if u ~= 0
                    coder.ceval("digitalWrite", uint8(obj.Pin), coder.opaque("uint8_t", "HIGH"));
                else
                    coder.ceval("digitalWrite", uint8(obj.Pin), coder.opaque("uint8_t", "LOW"));
                end
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
        %   See also: DIGITALOUTPUT, GETNUMOUTPUTSIMPL
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
        %   See also: DIGITALOUTPUT, GETNUMINPUTSIMPL
            num = 0;
        end

        function flag = isInputSizeMutableImpl(~, ~)
        %ISINPUTSIZEMUTABLEIMPL - Disallow mutable input size.
        %
        %   Syntax:
        %       flag = isInputSizeMutableImpl(~, ~)
        %
        %   Inputs:
        %       ~ - Unused system object.
        %       ~ - Unused input index.
        %
        %   Outputs:
        %       flag - false.
        %
        %   Example:
        %       % Queried by Simulink for input size mutability.
        %
        %   See also: DIGITALOUTPUT, GETNUMINPUTSIMPL
            flag = false;
        end

        function icon = getIconImpl(obj)
        %GETICONIMPL - Build the block icon string with the configured pin.
        %   Calls arduinopio.iconWithPin("Digital Output", obj.Pin).
        %
        %   Syntax:
        %       icon = getIconImpl(obj)
        %
        %   Inputs:
        %       obj - DigitalOutput system object.
        %
        %   Outputs:
        %       icon - Icon text from iconWithPin.
        %
        %   Example:
        %       % Used by Simulink to label the MATLAB System block.
        %
        %   See also: DIGITALOUTPUT, ICONWITHPIN
            icon = arduinopio.iconWithPin("Digital Output", obj.Pin);
        end

        function sts = getSampleTimeImpl(obj)
        %GETSAMPLETIMEIMPL - Inherited sample time when SampleTime is -1, else discrete.
        %   Uses createSampleTime Type="Inherited" or Type="Discrete" with obj.SampleTime.
        %
        %   Syntax:
        %       sts = getSampleTimeImpl(obj)
        %
        %   Inputs:
        %       obj - DigitalOutput system object.
        %
        %   Outputs:
        %       sts - Sample time specification object.
        %
        %   Example:
        %       % Queried by Simulink for sample-time propagation.
        %
        %   See also: DIGITALOUTPUT, CREATESAMPLETIME
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
        %       name - "Arduino PIO Digital Output".
        %
        %   Example:
        %       % Used by coder.ExternalDependency tooling.
        %
        %   See also: DIGITALOUTPUT, ISSUPPORTEDCONTEXT
            name = "Arduino PIO Digital Output";
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
        %   See also: DIGITALOUTPUT, UPDATEBUILDINFO
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
        %   See also: DIGITALOUTPUT, UPDATEDRIVERBUILDINFO
            arduinopio.updateDriverBuildInfo(buildInfo, context);
        end
    end

    methods (Static, Access = protected)
        function header = getHeaderImpl()
        %GETHEADERIMPL - Dialog header title and help text for the System block mask.
        %   Returns matlab.system.display.Header for arduinopio.blocks.common.DigitalOutput with
        %   Title "Digital Output" noting setupImpl/stepImpl emit pinMode/digitalWrite cevals.
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
        %   See also: DIGITALOUTPUT
            header = matlab.system.display.Header( ...
                "arduinopio.blocks.common.DigitalOutput", ...
                Title="Digital Output", ...
                Text="MATLAB System object path: setupImpl/stepImpl emit coder.ceval pinMode/digitalWrite.");
        end
    end
end
