classdef (Sealed) CanTransmit < matlab.System & coder.ExternalDependency
    %CANTRANSMIT - Send a CAN 2.0 frame through an MCP2515 controller on SPI.
    %   Sealed matlab.System and coder.ExternalDependency for MCP2515 transmit codegen. setupImpl
    %   includes arduinopio_can.h and calls arduinopioCanSetup. stepImpl truncates the Data input
    %   to at most 8 bytes and calls arduinopioCanSend when coder.target("Rtw"). SampleTime -1
    %   inherits; otherwise discrete. Host simulation is a no-op. Nontunable ChipSelectPin
    %   default 10, OscillatorMHz 8, BaudRateKbps 500, MessageId 256, ExtendedFrame false,
    %   RemoteFrame false, OperatingMode 0, SampleTime -1.
    %
    %   Syntax:
    %       obj = arduinopio.blocks.common.CanTransmit
    %       obj = arduinopio.blocks.common.CanTransmit(ChipSelectPin=10, MessageId=256, ...
    %           SampleTime=-1)
    %
    %   Inputs:
    %       ChipSelectPin - (1,1) nonnegative integer, default 10, validated as "digital".
    %       OscillatorMHz - member of [8, 16, 20], default 8.
    %       BaudRateKbps - member of [125, 250, 500, 1000], default 500.
    %       MessageId - (1,1) nonnegative integer, default 256; validated by validateCanIdentifier.
    %       ExtendedFrame - (1,1) logical, default false; selects standard vs extended ID rules.
    %       RemoteFrame - (1,1) logical, default false; remote-transmission-request flag.
    %       OperatingMode - integer in [0, 1, 2], default 0 (normal / loopback / listen-only).
    %       SampleTime - (1,1) double, default -1 (inherited) or positive discrete period.
    %
    %   Outputs:
    %       obj - Sealed matlab.System object. Step has 1 Data input and 0 outputs.
    %
    %   Example:
    %       obj = arduinopio.blocks.common.CanTransmit(ChipSelectPin=10, MessageId=256);
    %
    %   Other m-files required: arduinopio.validatePin, arduinopio.validateCanIdentifier,
    %       arduinopio.iconWithPin, arduinopio.updateDriverBuildInfo
    %   Subfunctions: none
    %   MAT-files required: none
    %
    %   See also: CANRECEIVE, VALIDATEPIN, VALIDATECANIDENTIFIER, UPDATEDRIVERBUILDINFO

    %   Author: Frey, Jed
    %   28-Sep-2026; Last revision: 28-Sep-2026

    properties (Nontunable)
        ChipSelectPin (1,1) {mustBeInteger, mustBeNonnegative} = 10
        OscillatorMHz (1,1) {mustBeMember(OscillatorMHz, [8, 16, 20])} = 8
        BaudRateKbps (1,1) {mustBeMember(BaudRateKbps, [125, 250, 500, 1000])} = 500
        MessageId (1,1) {mustBeInteger, mustBeNonnegative} = 256
        ExtendedFrame (1,1) logical = false
        RemoteFrame (1,1) logical = false
        OperatingMode (1,1) {mustBeInteger, mustBeMember(OperatingMode, [0, 1, 2])} = 0
        SampleTime (1,1) double = -1
    end

    methods
        function obj = CanTransmit(varargin)
        %CANTRANSMIT - Construct CanTransmit and apply Name-Value properties.
        %   Enables plain P-code via coder.allowpcode("plain"), then setProperties with varargin.
        %
        %   Syntax:
        %       obj = CanTransmit(varargin)
        %
        %   Inputs:
        %       varargin - Name-Value pairs for nontunable properties (ChipSelectPin,
        %           OscillatorMHz, BaudRateKbps, MessageId, ExtendedFrame, RemoteFrame,
        %           OperatingMode, SampleTime).
        %
        %   Outputs:
        %       obj - CanTransmit system object.
        %
        %   Example:
        %       obj = arduinopio.blocks.common.CanTransmit(MessageId=256);
        %
        %   See also: CANTRANSMIT, SETPROPERTIES
            coder.allowpcode("plain");
            setProperties(obj, nargin, varargin{:});
        end
    end

    methods (Access = protected)
        function validatePropertiesImpl(obj)
        %VALIDATEPROPERTIESIMPL - Validate CS pin and MessageId for the frame format.
        %   validatePin(ChipSelectPin, "digital") and validateCanIdentifier(MessageId,
        %   ExtendedFrame, "MessageId").
        %
        %   Syntax:
        %       validatePropertiesImpl(obj)
        %
        %   Inputs:
        %       obj - CanTransmit system object.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       % Invoked by the System object framework before setup.
        %
        %   See also: CANTRANSMIT, VALIDATEPIN, VALIDATECANIDENTIFIER
            arduinopio.validatePin(obj.ChipSelectPin, "digital");
            arduinopio.validateCanIdentifier(obj.MessageId, obj.ExtendedFrame, "MessageId");
        end

        function setupImpl(obj)
        %SETUPIMPL - Initialize MCP2515 via arduinopioCanSetup when generating code.
        %   Under coder.target("Rtw"), includes arduinopio_can.h and calls arduinopioCanSetup with
        %   CS, baud, oscillator MHz, and OperatingMode. Host simulation is a no-op.
        %
        %   Syntax:
        %       setupImpl(obj)
        %
        %   Inputs:
        %       obj - CanTransmit system object.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       % Invoked once before stepping during codegen.
        %
        %   See also: CANTRANSMIT, STEPIMPL
            if coder.target("Rtw")
                coder.cinclude("arduinopio_can.h");
                coder.ceval("arduinopioCanSetup", uint8(obj.ChipSelectPin), uint16(obj.BaudRateKbps), ...
                    uint8(obj.OscillatorMHz), uint8(obj.OperatingMode));
            end
        end

        function stepImpl(obj, u)
        %STEPIMPL - Transmit up to 8 payload bytes with arduinopioCanSend under RTW.
        %   Under coder.target("Rtw"), casts u(:) to uint8, truncates to maxPayload 8, then
        %   cevals arduinopioCanSend with MessageId, ExtendedFrame, RemoteFrame, data ref, and
        %   length. Host simulation is a no-op.
        %
        %   Syntax:
        %       stepImpl(obj, u)
        %
        %   Inputs:
        %       obj - CanTransmit system object.
        %       u - Payload vector; cast to uint8 and truncated to at most 8 elements.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       % Invoked by the System object step method during codegen.
        %
        %   See also: CANTRANSMIT, SETUPIMPL
            if coder.target("Rtw")
                data = uint8(u(:));
                maxPayload = 8;
                if numel(data) > maxPayload
                    data = data(1:maxPayload);
                end
                coder.ceval("arduinopioCanSend", uint32(obj.MessageId), uint8(obj.ExtendedFrame), ...
                    uint8(obj.RemoteFrame), coder.rref(data), uint8(numel(data)));
            end
        end

        function names = getInputNamesImpl(~)
        %GETINPUTNAMESIMPL - Return the single input port name Data.
        %
        %   Syntax:
        %       names = getInputNamesImpl(~)
        %
        %   Inputs:
        %       ~ - Unused system object.
        %
        %   Outputs:
        %       names - "Data".
        %
        %   Example:
        %       % Used by Simulink to label the input port.
        %
        %   See also: CANTRANSMIT, GETNUMINPUTSIMPL
            names = "Data";
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
        %   See also: CANTRANSMIT, GETNUMOUTPUTSIMPL
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
        %   See also: CANTRANSMIT, GETNUMINPUTSIMPL
            num = 0;
        end

        function icon = getIconImpl(obj)
        %GETICONIMPL - Build the block icon with CS pin labeled.
        %   Calls iconWithPin("CAN Transmit", obj.ChipSelectPin, Label="CS").
        %
        %   Syntax:
        %       icon = getIconImpl(obj)
        %
        %   Inputs:
        %       obj - CanTransmit system object.
        %
        %   Outputs:
        %       icon - Icon text from iconWithPin.
        %
        %   Example:
        %       % Used by Simulink to label the MATLAB System block.
        %
        %   See also: CANTRANSMIT, ICONWITHPIN
            icon = arduinopio.iconWithPin("CAN Transmit", obj.ChipSelectPin, Label="CS");
        end

        function sts = getSampleTimeImpl(obj)
        %GETSAMPLETIMEIMPL - Inherited sample time when SampleTime is -1, else discrete.
        %   Uses createSampleTime Type="Inherited" or Type="Discrete" with obj.SampleTime.
        %
        %   Syntax:
        %       sts = getSampleTimeImpl(obj)
        %
        %   Inputs:
        %       obj - CanTransmit system object.
        %
        %   Outputs:
        %       sts - Sample time specification object.
        %
        %   Example:
        %       % Queried by Simulink for sample-time propagation.
        %
        %   See also: CANTRANSMIT, CREATESAMPLETIME
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
        %       name - "Arduino PIO CAN Transmit".
        %
        %   Example:
        %       % Used by coder.ExternalDependency tooling.
        %
        %   See also: CANTRANSMIT, ISSUPPORTEDCONTEXT
            name = "Arduino PIO CAN Transmit";
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
        %   See also: CANTRANSMIT, UPDATEBUILDINFO
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
        %   See also: CANTRANSMIT, UPDATEDRIVERBUILDINFO
            arduinopio.updateDriverBuildInfo(buildInfo, context, "arduinopio_can.cpp", "MCP2515");
        end
    end

    methods (Static, Access = protected)
        function header = getHeaderImpl()
        %GETHEADERIMPL - Dialog header title and help text for the System block mask.
        %   Returns Header for CanTransmit documenting SPI pins, OperatingMode codes, and CS
        %   defaults including Seeed shield CS=9 note.
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
        %   See also: CANTRANSMIT
            header = matlab.system.display.Header( ...
                "arduinopio.blocks.common.CanTransmit", ...
                Title="CAN Transmit", ...
                Text="MCP2515 over SPI (Uno MOSI=11, MISO=12, SCK=13). OperatingMode: 0=normal, 1=loopback, 2=listen-only. Default CS=10; Seeed CAN-BUS Shield often uses CS=9.");
        end
    end
end
