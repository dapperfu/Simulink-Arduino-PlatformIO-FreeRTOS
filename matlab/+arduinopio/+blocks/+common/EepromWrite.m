classdef (Sealed) EepromWrite < matlab.System & coder.ExternalDependency
    %EEPROMWRITE - Write bytes to on-board EEPROM starting at a configured address.
    %   Sealed matlab.System and coder.ExternalDependency for EEPROM write codegen. Uno has 1024
    %   bytes at addresses 0-1023. setupImpl includes arduinopio_eeprom.h and calls
    %   arduinopioEepromSetup. stepImpl casts the input to uint8 and calls arduinopioEepromWrite
    %   when coder.target("Rtw"). SampleTime -1 inherits; otherwise discrete. Host simulation is
    %   a no-op. Nontunable StartAddress default 0 and SampleTime default -1. Range check uses
    %   length 1 at validation; write length follows numel of the step input.
    %
    %   Syntax:
    %       obj = arduinopio.blocks.common.EepromWrite
    %       obj = arduinopio.blocks.common.EepromWrite(StartAddress=0, SampleTime=-1)
    %
    %   Inputs:
    %       StartAddress - (1,1) nonnegative integer, default 0; validated with length 1.
    %       SampleTime - (1,1) double, default -1 (inherited) or positive discrete period.
    %
    %   Outputs:
    %       obj - Sealed matlab.System object. Step has 1 data input and 0 outputs.
    %
    %   Example:
    %       obj = arduinopio.blocks.common.EepromWrite(StartAddress=0);
    %
    %   Other m-files required: arduinopio.validateEepromRange, arduinopio.updateDriverBuildInfo
    %   Subfunctions: none
    %   MAT-files required: none
    %
    %   See also: EEPROMREAD, VALIDATEEEPROMRANGE, UPDATEDRIVERBUILDINFO

    %   Author: Frey, Jed
    %   28-Sep-2026; Last revision: 28-Sep-2026

    properties (Nontunable)
        StartAddress (1,1) {mustBeInteger, mustBeNonnegative} = 0
        SampleTime (1,1) double = -1
    end

    methods
        function obj = EepromWrite(varargin)
        %EEPROMWRITE - Construct EepromWrite and apply Name-Value properties.
        %   Enables plain P-code via coder.allowpcode("plain"), then setProperties with varargin.
        %
        %   Syntax:
        %       obj = EepromWrite(varargin)
        %
        %   Inputs:
        %       varargin - Name-Value pairs for nontunable properties (StartAddress, SampleTime).
        %
        %   Outputs:
        %       obj - EepromWrite system object.
        %
        %   Example:
        %       obj = arduinopio.blocks.common.EepromWrite(StartAddress=16);
        %
        %   See also: EEPROMWRITE, SETPROPERTIES
            coder.allowpcode("plain");
            setProperties(obj, nargin, varargin{:});
        end
    end

    methods (Access = protected)
        function validatePropertiesImpl(obj)
        %VALIDATEPROPERTIESIMPL - Ensure StartAddress is valid for at least one EEPROM byte.
        %   Calls arduinopio.validateEepromRange(obj.StartAddress, 1).
        %
        %   Syntax:
        %       validatePropertiesImpl(obj)
        %
        %   Inputs:
        %       obj - EepromWrite system object.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       % Invoked by the System object framework before setup.
        %
        %   See also: EEPROMWRITE, VALIDATEEEPROMRANGE
            arduinopio.validateEepromRange(obj.StartAddress, 1);
        end

        function setupImpl(~)
        %SETUPIMPL - Initialize EEPROM access via arduinopioEepromSetup under RTW.
        %   Under coder.target("Rtw"), includes arduinopio_eeprom.h and calls
        %   arduinopioEepromSetup. Host simulation is a no-op.
        %
        %   Syntax:
        %       setupImpl(~)
        %
        %   Inputs:
        %       ~ - Unused system object.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       % Invoked once before stepping during codegen.
        %
        %   See also: EEPROMWRITE, STEPIMPL
            if coder.target("Rtw")
                coder.cinclude("arduinopio_eeprom.h");
                coder.ceval("arduinopioEepromSetup");
            end
        end

        function stepImpl(obj, u)
        %STEPIMPL - Write uint8 payload with arduinopioEepromWrite under RTW.
        %   Under coder.target("Rtw"), sets data = uint8(u(:)) and cevals
        %   arduinopioEepromWrite(StartAddress, rref(data), numel(data)). Host is a no-op.
        %
        %   Syntax:
        %       stepImpl(obj, u)
        %
        %   Inputs:
        %       obj - EepromWrite system object.
        %       u - Bytes to write; cast to uint8 column and length from numel(data).
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       % Invoked by the System object step method during codegen.
        %
        %   See also: EEPROMWRITE, SETUPIMPL
            if coder.target("Rtw")
                data = uint8(u(:));
                coder.ceval("arduinopioEepromWrite", uint16(obj.StartAddress), coder.rref(data), uint8(numel(data)));
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
        %   See also: EEPROMWRITE, GETNUMOUTPUTSIMPL
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
        %   See also: EEPROMWRITE, GETNUMINPUTSIMPL
            num = 0;
        end

        function icon = getIconImpl(~)
        %GETICONIMPL - Return the fixed block icon label EEPROM Write.
        %
        %   Syntax:
        %       icon = getIconImpl(~)
        %
        %   Inputs:
        %       ~ - Unused system object.
        %
        %   Outputs:
        %       icon - "EEPROM Write".
        %
        %   Example:
        %       % Used by Simulink to label the MATLAB System block.
        %
        %   See also: EEPROMWRITE
            icon = "EEPROM Write";
        end

        function sts = getSampleTimeImpl(obj)
        %GETSAMPLETIMEIMPL - Inherited sample time when SampleTime is -1, else discrete.
        %   Uses createSampleTime Type="Inherited" or Type="Discrete" with obj.SampleTime.
        %
        %   Syntax:
        %       sts = getSampleTimeImpl(obj)
        %
        %   Inputs:
        %       obj - EepromWrite system object.
        %
        %   Outputs:
        %       sts - Sample time specification object.
        %
        %   Example:
        %       % Queried by Simulink for sample-time propagation.
        %
        %   See also: EEPROMWRITE, CREATESAMPLETIME
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
        %       name - "Arduino PIO EEPROM Write".
        %
        %   Example:
        %       % Used by coder.ExternalDependency tooling.
        %
        %   See also: EEPROMWRITE, ISSUPPORTEDCONTEXT
            name = "Arduino PIO EEPROM Write";
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
        %   See also: EEPROMWRITE, UPDATEBUILDINFO
            tf = context.isCodeGenTarget("rtw");
        end

        function updateBuildInfo(buildInfo, context)
        %UPDATEBUILDINFO - Add EEPROM driver source to the RTW build.
        %   Calls updateDriverBuildInfo(buildInfo, context, "arduinopio_eeprom.cpp").
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
        %   See also: EEPROMWRITE, UPDATEDRIVERBUILDINFO
            arduinopio.updateDriverBuildInfo(buildInfo, context, "arduinopio_eeprom.cpp");
        end
    end
end
