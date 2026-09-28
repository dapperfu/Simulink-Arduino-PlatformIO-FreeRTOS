classdef (Sealed) EepromRead < matlab.System & coder.ExternalDependency
    %EEPROMREAD - Read bytes from on-board EEPROM starting at a configured address.
    %   Sealed matlab.System and coder.ExternalDependency for EEPROM read codegen. Uno has 1024
    %   bytes at addresses 0-1023. setupImpl includes arduinopio_eeprom.h and calls
    %   arduinopioEepromSetup. stepImpl calls arduinopioEepromRead into a DataLength-by-1 uint8
    %   buffer when coder.target("Rtw"). SampleTime -1 inherits; otherwise discrete. Host
    %   simulation returns zeros and does not touch hardware. Nontunable StartAddress default 0,
    %   DataLength default 1, SampleTime default -1.
    %
    %   Syntax:
    %       obj = arduinopio.blocks.common.EepromRead
    %       obj = arduinopio.blocks.common.EepromRead(StartAddress=0, DataLength=1, SampleTime=-1)
    %
    %   Inputs:
    %       StartAddress - (1,1) nonnegative integer, default 0; range-checked with DataLength.
    %       DataLength - (1,1) positive integer, default 1; number of bytes to read.
    %       SampleTime - (1,1) double, default -1 (inherited) or positive discrete period.
    %
    %   Outputs:
    %       obj - Sealed matlab.System. Step has 0 inputs and 1 uint8 column vector of DataLength.
    %
    %   Example:
    %       obj = arduinopio.blocks.common.EepromRead(StartAddress=0, DataLength=4);
    %
    %   Other m-files required: arduinopio.validateEepromRange, arduinopio.updateDriverBuildInfo
    %   Subfunctions: none
    %   MAT-files required: none
    %
    %   See also: EEPROMWRITE, VALIDATEEEPROMRANGE, UPDATEDRIVERBUILDINFO

    %   Author: Frey, Jed
    %   28-Sep-2026; Last revision: 28-Sep-2026

    properties (Nontunable)
        StartAddress (1,1) {mustBeInteger, mustBeNonnegative} = 0
        DataLength (1,1) {mustBeInteger, mustBePositive} = 1
        SampleTime (1,1) double = -1
    end

    methods
        function obj = EepromRead(varargin)
        %EEPROMREAD - Construct EepromRead and apply Name-Value properties.
        %   Enables plain P-code via coder.allowpcode("plain"), then setProperties with varargin.
        %
        %   Syntax:
        %       obj = EepromRead(varargin)
        %
        %   Inputs:
        %       varargin - Name-Value pairs for nontunable properties (StartAddress, DataLength,
        %           SampleTime).
        %
        %   Outputs:
        %       obj - EepromRead system object.
        %
        %   Example:
        %       obj = arduinopio.blocks.common.EepromRead(DataLength=8);
        %
        %   See also: EEPROMREAD, SETPROPERTIES
            coder.allowpcode("plain");
            setProperties(obj, nargin, varargin{:});
        end
    end

    methods (Access = protected)
        function validatePropertiesImpl(obj)
        %VALIDATEPROPERTIESIMPL - Ensure StartAddress and DataLength fit EEPROM capacity.
        %   Calls arduinopio.validateEepromRange(obj.StartAddress, obj.DataLength).
        %
        %   Syntax:
        %       validatePropertiesImpl(obj)
        %
        %   Inputs:
        %       obj - EepromRead system object.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       % Invoked by the System object framework before setup.
        %
        %   See also: EEPROMREAD, VALIDATEEEPROMRANGE
            arduinopio.validateEepromRange(obj.StartAddress, obj.DataLength);
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
        %   See also: EEPROMREAD, STEPIMPL
            if coder.target("Rtw")
                coder.cinclude("arduinopio_eeprom.h");
                coder.ceval("arduinopioEepromSetup");
            end
        end

        function data = stepImpl(obj)
        %STEPIMPL - Read DataLength bytes with arduinopioEepromRead under RTW.
        %   Defaults data to zeros(obj.DataLength, 1, "uint8"). Under coder.target("Rtw"),
        %   cevals arduinopioEepromRead(StartAddress, wref(data), DataLength). Host leaves zeros.
        %
        %   Syntax:
        %       data = stepImpl(obj)
        %
        %   Inputs:
        %       obj - EepromRead system object.
        %
        %   Outputs:
        %       data - (DataLength, 1) uint8; zeros on host, EEPROM contents under RTW.
        %
        %   Example:
        %       % Invoked by the System object step method during codegen.
        %
        %   See also: EEPROMREAD, SETUPIMPL
            data = zeros(obj.DataLength, 1, "uint8");
            if coder.target("Rtw")
                coder.ceval("arduinopioEepromRead", uint16(obj.StartAddress), coder.wref(data), uint8(obj.DataLength));
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
        %   See also: EEPROMREAD, GETNUMOUTPUTSIMPL
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
        %   See also: EEPROMREAD, GETNUMINPUTSIMPL
            num = 1;
        end

        function sz = getOutputSizeImpl(obj)
        %GETOUTPUTSIZEIMPL - Return output size [DataLength, 1].
        %
        %   Syntax:
        %       sz = getOutputSizeImpl(obj)
        %
        %   Inputs:
        %       obj - EepromRead system object.
        %
        %   Outputs:
        %       sz - [obj.DataLength, 1].
        %
        %   Example:
        %       % Queried by Simulink for signal sizes.
        %
        %   See also: EEPROMREAD, GETOUTPUTDATATYPEIMPL
            sz = [obj.DataLength, 1];
        end

        function dt = getOutputDataTypeImpl(~)
        %GETOUTPUTDATATYPEIMPL - Return output data type uint8.
        %
        %   Syntax:
        %       dt = getOutputDataTypeImpl(~)
        %
        %   Inputs:
        %       ~ - Unused system object.
        %
        %   Outputs:
        %       dt - "uint8".
        %
        %   Example:
        %       % Queried by Simulink for signal types.
        %
        %   See also: EEPROMREAD, GETOUTPUTSIZEIMPL
            dt = "uint8";
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
        %   See also: EEPROMREAD, ISOUTPUTFIXEDSIZEIMPL
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
        %   See also: EEPROMREAD, ISOUTPUTCOMPLEXIMPL
            f = true;
        end

        function icon = getIconImpl(~)
        %GETICONIMPL - Return the fixed block icon label EEPROM Read.
        %
        %   Syntax:
        %       icon = getIconImpl(~)
        %
        %   Inputs:
        %       ~ - Unused system object.
        %
        %   Outputs:
        %       icon - "EEPROM Read".
        %
        %   Example:
        %       % Used by Simulink to label the MATLAB System block.
        %
        %   See also: EEPROMREAD
            icon = "EEPROM Read";
        end

        function sts = getSampleTimeImpl(obj)
        %GETSAMPLETIMEIMPL - Inherited sample time when SampleTime is -1, else discrete.
        %   Uses createSampleTime Type="Inherited" or Type="Discrete" with obj.SampleTime.
        %
        %   Syntax:
        %       sts = getSampleTimeImpl(obj)
        %
        %   Inputs:
        %       obj - EepromRead system object.
        %
        %   Outputs:
        %       sts - Sample time specification object.
        %
        %   Example:
        %       % Queried by Simulink for sample-time propagation.
        %
        %   See also: EEPROMREAD, CREATESAMPLETIME
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
        %       name - "Arduino PIO EEPROM Read".
        %
        %   Example:
        %       % Used by coder.ExternalDependency tooling.
        %
        %   See also: EEPROMREAD, ISSUPPORTEDCONTEXT
            name = "Arduino PIO EEPROM Read";
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
        %   See also: EEPROMREAD, UPDATEBUILDINFO
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
        %   See also: EEPROMREAD, UPDATEDRIVERBUILDINFO
            arduinopio.updateDriverBuildInfo(buildInfo, context, "arduinopio_eeprom.cpp");
        end
    end
end
