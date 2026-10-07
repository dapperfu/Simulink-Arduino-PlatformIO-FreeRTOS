classdef (Sealed) CanReceive < matlab.System & coder.ExternalDependency
    %CANRECEIVE - Read a CAN 2.0 frame from an MCP2515 controller on SPI.
    %   Sealed matlab.System and coder.ExternalDependency for MCP2515 receive codegen. setupImpl
    %   includes arduinopio_can.h, calls arduinopioCanSetup, arduinopioCanSetReceiveTimeout, and
    %   optionally arduinopioCanSetFilter when UseFilter is true. The C driver runs a FreeRTOS
    %   RX task (1 ms) that drains MCP2515 into a queue under a mutex; stepImpl takes from that
    %   queue via arduinopioCanReceive with ReceiveTimeoutMs (default 10). SampleTime -1
    %   inherits; otherwise discrete. Host simulation returns zeroed outputs and Status false
    %   without touching hardware. Nontunable ChipSelectPin default 10, OscillatorMHz 8,
    %   BaudRateKbps 500, OperatingMode 0, UseFilter false, FilterId 0, FilterMask 2047,
    %   FilterExtended false, ReceiveTimeoutMs 10, SampleTime -1.
    %
    %   Syntax:
    %       obj = arduinopio.blocks.common.CanReceive
    %       obj = arduinopio.blocks.common.CanReceive(ChipSelectPin=10, BaudRateKbps=500, ...
    %           SampleTime=-1)
    %
    %   Inputs:
    %       ChipSelectPin - (1,1) nonnegative integer, default 10, validated as "digital".
    %       OscillatorMHz - member of [8, 16, 20], default 8.
    %       BaudRateKbps - member of [125, 250, 500, 1000], default 500.
    %       OperatingMode - integer in [0, 1, 2], default 0 (normal / loopback / listen-only).
    %       UseFilter - (1,1) logical, default false; when true programs MASK/RXF in setup.
    %       FilterId - (1,1) nonnegative integer, default 0; validated by validateCanIdentifier.
    %       FilterMask - (1,1) nonnegative integer, default 2047; validated by validateCanIdentifier.
    %       FilterExtended - (1,1) logical, default false; selects standard vs extended ID rules.
    %       ReceiveTimeoutMs - (1,1) nonnegative integer, default 10; FreeRTOS queue wait in ms.
    %       SampleTime - (1,1) double, default -1 (inherited) or positive discrete period.
    %
    %   Outputs:
    %       obj - Sealed matlab.System. Step has 0 inputs and 4 outputs: Id, Data, Length, Status.
    %
    %   Example:
    %       obj = arduinopio.blocks.common.CanReceive(ChipSelectPin=10, UseFilter=true);
    %
    %   Other m-files required: arduinopio.validatePin, arduinopio.validateCanIdentifier,
    %       arduinopio.iconWithPin, arduinopio.updateDriverBuildInfo
    %   Subfunctions: none
    %   MAT-files required: none
    %
    %   See also: CANTRANSMIT, VALIDATEPIN, VALIDATECANIDENTIFIER, UPDATEDRIVERBUILDINFO

    %   Author: Frey, Jed
    %   28-Sep-2026; Last revision: 07-Oct-2026

    properties (Nontunable)
        ChipSelectPin (1,1) {mustBeInteger, mustBeNonnegative} = 10
        OscillatorMHz (1,1) {mustBeMember(OscillatorMHz, [8, 16, 20])} = 8
        BaudRateKbps (1,1) {mustBeMember(BaudRateKbps, [125, 250, 500, 1000])} = 500
        OperatingMode (1,1) {mustBeInteger, mustBeMember(OperatingMode, [0, 1, 2])} = 0
        UseFilter (1,1) logical = false
        FilterId (1,1) {mustBeInteger, mustBeNonnegative} = 0
        FilterMask (1,1) {mustBeInteger, mustBeNonnegative} = 2047
        FilterExtended (1,1) logical = false
        ReceiveTimeoutMs (1,1) {mustBeInteger, mustBeNonnegative} = 10
        SampleTime (1,1) double = -1
    end

    methods
        function obj = CanReceive(varargin)
        %CANRECEIVE - Construct CanReceive and apply Name-Value properties.
        %   Enables plain P-code via coder.allowpcode("plain"), then setProperties with varargin.
        %
        %   Syntax:
        %       obj = CanReceive(varargin)
        %
        %   Inputs:
        %       varargin - Name-Value pairs for nontunable properties (ChipSelectPin,
        %           OscillatorMHz, BaudRateKbps, OperatingMode, UseFilter, FilterId, FilterMask,
        %           FilterExtended, ReceiveTimeoutMs, SampleTime).
        %
        %   Outputs:
        %       obj - CanReceive system object.
        %
        %   Example:
        %       obj = arduinopio.blocks.common.CanReceive(ChipSelectPin=10);
        %
        %   See also: CANRECEIVE, SETPROPERTIES
            coder.allowpcode("plain");
            setProperties(obj, nargin, varargin{:});
        end
    end

    methods (Access = protected)
        function validatePropertiesImpl(obj)
        %VALIDATEPROPERTIESIMPL - Validate CS pin and optional CAN filter identifiers.
        %   validatePin(ChipSelectPin, "digital"); validateCanIdentifier on FilterId and
        %   FilterMask using FilterExtended.
        %
        %   Syntax:
        %       validatePropertiesImpl(obj)
        %
        %   Inputs:
        %       obj - CanReceive system object.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       % Invoked by the System object framework before setup.
        %
        %   See also: CANRECEIVE, VALIDATEPIN, VALIDATECANIDENTIFIER
            arduinopio.validatePin(obj.ChipSelectPin, "digital");
            arduinopio.validateCanIdentifier(obj.FilterId, obj.FilterExtended, "FilterId");
            arduinopio.validateCanIdentifier(obj.FilterMask, obj.FilterExtended, "FilterMask");
        end

        function setupImpl(obj)
        %SETUPIMPL - Initialize MCP2515, receive timeout, and optional RX filter for codegen.
        %   Under coder.target("Rtw"), includes arduinopio_can.h, calls arduinopioCanSetup with
        %   CS, baud, oscillator MHz, and OperatingMode; sets ReceiveTimeoutMs via
        %   arduinopioCanSetReceiveTimeout; if UseFilter, calls arduinopioCanSetFilter. Host
        %   simulation is a no-op.
        %
        %   Syntax:
        %       setupImpl(obj)
        %
        %   Inputs:
        %       obj - CanReceive system object.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       % Invoked once before stepping during codegen.
        %
        %   See also: CANRECEIVE, STEPIMPL
            if coder.target("Rtw")
                coder.cinclude("arduinopio_can.h");
                coder.ceval("arduinopioCanSetup", uint8(obj.ChipSelectPin), uint16(obj.BaudRateKbps), ...
                    uint8(obj.OscillatorMHz), uint8(obj.OperatingMode));
                coder.ceval("arduinopioCanSetReceiveTimeout", uint16(obj.ReceiveTimeoutMs));
                if obj.UseFilter
                    coder.ceval("arduinopioCanSetFilter", uint8(obj.FilterExtended), ...
                        uint32(obj.FilterId), uint32(obj.FilterMask));
                end
            end
        end

        function [identifier, data, length, status] = stepImpl(~)
        %STEPIMPL - Take a queued MCP2515 frame via arduinopioCanReceive under RTW.
        %   Defaults: identifier uint32(0), data zeros(8,1,"uint8"), length uint8(0), status
        %   false. Under RTW, ceval fills identifier/data/length via wref; status is true when
        %   gotFrame ~= 0. The driver waits up to ReceiveTimeoutMs on the FreeRTOS RX queue.
        %   Host leaves defaults and does not access hardware.
        %
        %   Syntax:
        %       [identifier, data, length, status] = stepImpl(~)
        %
        %   Inputs:
        %       ~ - Unused system object.
        %
        %   Outputs:
        %       identifier - (1,1) uint32 CAN ID.
        %       data - (8,1) uint8 payload buffer.
        %       length - (1,1) uint8 DLC.
        %       status - (1,1) logical true when a new frame was read.
        %
        %   Example:
        %       % Invoked by the System object step method during codegen.
        %
        %   See also: CANRECEIVE, SETUPIMPL
            identifier = uint32(0);
            data = zeros(8, 1, "uint8");
            length = uint8(0);
            status = false;
            if coder.target("Rtw")
                extended = uint8(0);
                remote = uint8(0);
                gotFrame = uint8(0);
                gotFrame = coder.ceval("arduinopioCanReceive", coder.wref(identifier), coder.wref(extended), ...
                    coder.wref(remote), coder.wref(data), coder.wref(length));
                status = (gotFrame ~= 0);
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
        %   See also: CANRECEIVE, GETNUMOUTPUTSIMPL
            num = 0;
        end

        function names = getOutputNamesImpl(~)
        %GETOUTPUTNAMESIMPL - Return output port names Id, Data, Length, Status.
        %
        %   Syntax:
        %       names = getOutputNamesImpl(~)
        %
        %   Inputs:
        %       ~ - Unused system object.
        %
        %   Outputs:
        %       names - string array ["Id", "Data", "Length", "Status"].
        %
        %   Example:
        %       % Used by Simulink to label output ports.
        %
        %   See also: CANRECEIVE, GETNUMOUTPUTSIMPL
            names = ["Id", "Data", "Length", "Status"];
        end

        function num = getNumOutputsImpl(~)
        %GETNUMOUTPUTSIMPL - Report four System object step outputs.
        %
        %   Syntax:
        %       num = getNumOutputsImpl(~)
        %
        %   Inputs:
        %       ~ - Unused system object.
        %
        %   Outputs:
        %       num - 4.
        %
        %   Example:
        %       % Queried by Simulink for port counts.
        %
        %   See also: CANRECEIVE, GETNUMINPUTSIMPL
            num = 4;
        end

        function [sz1, sz2, sz3, sz4] = getOutputSizeImpl(~)
        %GETOUTPUTSIZEIMPL - Return sizes [1,1], [8,1], [1,1], [1,1] for the four outputs.
        %
        %   Syntax:
        %       [sz1, sz2, sz3, sz4] = getOutputSizeImpl(~)
        %
        %   Inputs:
        %       ~ - Unused system object.
        %
        %   Outputs:
        %       sz1 - [1, 1] for Id.
        %       sz2 - [8, 1] for Data.
        %       sz3 - [1, 1] for Length.
        %       sz4 - [1, 1] for Status.
        %
        %   Example:
        %       % Queried by Simulink for signal sizes.
        %
        %   See also: CANRECEIVE, GETOUTPUTDATATYPEIMPL
            sz1 = [1, 1];
            sz2 = [8, 1];
            sz3 = [1, 1];
            sz4 = [1, 1];
        end

        function [dt1, dt2, dt3, dt4] = getOutputDataTypeImpl(~)
        %GETOUTPUTDATATYPEIMPL - Return uint32, uint8, uint8, logical for the four outputs.
        %
        %   Syntax:
        %       [dt1, dt2, dt3, dt4] = getOutputDataTypeImpl(~)
        %
        %   Inputs:
        %       ~ - Unused system object.
        %
        %   Outputs:
        %       dt1 - "uint32" for Id.
        %       dt2 - "uint8" for Data.
        %       dt3 - "uint8" for Length.
        %       dt4 - "logical" for Status.
        %
        %   Example:
        %       % Queried by Simulink for signal types.
        %
        %   See also: CANRECEIVE, GETOUTPUTSIZEIMPL
            dt1 = "uint32";
            dt2 = "uint8";
            dt3 = "uint8";
            dt4 = "logical";
        end

        function [c1, c2, c3, c4] = isOutputComplexImpl(~)
        %ISOUTPUTCOMPLEXIMPL - Report that all four outputs are real-valued.
        %
        %   Syntax:
        %       [c1, c2, c3, c4] = isOutputComplexImpl(~)
        %
        %   Inputs:
        %       ~ - Unused system object.
        %
        %   Outputs:
        %       c1, c2, c3, c4 - all false.
        %
        %   Example:
        %       % Queried by Simulink for complexity.
        %
        %   See also: CANRECEIVE, ISOUTPUTFIXEDSIZEIMPL
            c1 = false;
            c2 = false;
            c3 = false;
            c4 = false;
        end

        function [f1, f2, f3, f4] = isOutputFixedSizeImpl(~)
        %ISOUTPUTFIXEDSIZEIMPL - Report that all four output sizes are fixed.
        %
        %   Syntax:
        %       [f1, f2, f3, f4] = isOutputFixedSizeImpl(~)
        %
        %   Inputs:
        %       ~ - Unused system object.
        %
        %   Outputs:
        %       f1, f2, f3, f4 - all true.
        %
        %   Example:
        %       % Queried by Simulink for size mutability.
        %
        %   See also: CANRECEIVE, ISOUTPUTCOMPLEXIMPL
            f1 = true;
            f2 = true;
            f3 = true;
            f4 = true;
        end

        function icon = getIconImpl(obj)
        %GETICONIMPL - Build the block icon with CS pin labeled.
        %   Calls iconWithPin("CAN Receive", obj.ChipSelectPin, Label="CS").
        %
        %   Syntax:
        %       icon = getIconImpl(obj)
        %
        %   Inputs:
        %       obj - CanReceive system object.
        %
        %   Outputs:
        %       icon - Icon text from iconWithPin.
        %
        %   Example:
        %       % Used by Simulink to label the MATLAB System block.
        %
        %   See also: CANRECEIVE, ICONWITHPIN
            icon = arduinopio.iconWithPin("CAN Receive", obj.ChipSelectPin, Label="CS");
        end

        function sts = getSampleTimeImpl(obj)
        %GETSAMPLETIMEIMPL - Inherited sample time when SampleTime is -1, else discrete.
        %   Uses createSampleTime Type="Inherited" or Type="Discrete" with obj.SampleTime.
        %
        %   Syntax:
        %       sts = getSampleTimeImpl(obj)
        %
        %   Inputs:
        %       obj - CanReceive system object.
        %
        %   Outputs:
        %       sts - Sample time specification object.
        %
        %   Example:
        %       % Queried by Simulink for sample-time propagation.
        %
        %   See also: CANRECEIVE, CREATESAMPLETIME
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
        %       name - "Arduino PIO CAN Receive".
        %
        %   Example:
        %       % Used by coder.ExternalDependency tooling.
        %
        %   See also: CANRECEIVE, ISSUPPORTEDCONTEXT
            name = "Arduino PIO CAN Receive";
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
        %   See also: CANRECEIVE, UPDATEBUILDINFO
            tf = context.isCodeGenTarget("rtw");
        end

        function updateBuildInfo(buildInfo, context)
        %UPDATEBUILDINFO - Add CAN driver source and autowp MCP2515 library dependency.
        %   Calls updateDriverBuildInfo(buildInfo, context, "arduinopio_can.cpp", "MCP2515"),
        %   which maps to PlatformIO lib_deps entry autowp/autowp-mcp2515.
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
        %   See also: CANRECEIVE, UPDATEDRIVERBUILDINFO
            arduinopio.updateDriverBuildInfo(buildInfo, context, "arduinopio_can.cpp", "MCP2515");
        end
    end

    methods (Static, Access = protected)
        function header = getHeaderImpl()
        %GETHEADERIMPL - Dialog header title and help text for the System block mask.
        %   Returns Header for CanReceive: polls MCP2515 each sample; Status true on new frame;
        %   UseFilter programs MASK/RXF when selected.
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
        %   See also: CANRECEIVE
            header = matlab.system.display.Header( ...
                "arduinopio.blocks.common.CanReceive", ...
                Title="CAN Receive", ...
                Text="FreeRTOS RX task drains MCP2515 into a queue (mutex-protected SPI). Status is true when a frame is taken within ReceiveTimeoutMs (default 10). UseFilter programs MASK/RXF when selected.");
        end
    end
end
