classdef (Sealed) SerialTransmit < matlab.System & coder.ExternalDependency
    %SERIALTRANSMIT - Send bytes on an Arduino hardware UART port.
    %   Sealed matlab.System plus coder.ExternalDependency. Uno uses Serial0 on
    %   pins 0 and 1. Nontunable Port defaults to 0, BaudRate to 9600,
    %   SampleTime to -1 (inherited). validatePropertiesImpl calls
    %   arduinopio.validateUartPort. On RTW, setupImpl includes
    %   arduinopio_uart.h and calls arduinopioUartSetup(Port, BaudRate).
    %   stepImpl casts the input to a uint8 column and calls arduinopioUartWrite.
    %   Host simulation performs no write. updateBuildInfo adds
    %   arduinopio_uart.cpp. The Common library block uses Level-2 MATLAB
    %   S-function arduinopio_serial_transmit instead of this System object.
    %
    %   Syntax:
    %       obj = arduinopio.blocks.common.SerialTransmit
    %       obj = arduinopio.blocks.common.SerialTransmit(Name=value)
    %
    %   Inputs:
    %       Port       - (1,1) nonnegative integer UART port. Default: 0.
    %       BaudRate   - (1,1) positive integer baud rate. Default: 9600.
    %       SampleTime - (1,1) double. Default: -1 (inherited).
    %       u (step)   - Bytes to transmit; cast to uint8 column in stepImpl.
    %
    %   Outputs:
    %       obj - SerialTransmit System object. stepImpl has one input, no outputs.
    %
    %   Example:
    %       obj = arduinopio.blocks.common.SerialTransmit(BaudRate=115200);
    %
    %   Other m-files required: arduinopio.validateUartPort,
    %       arduinopio.updateDriverBuildInfo
    %   Subfunctions: none
    %   MAT-files required: none
    %
    %   See also: SERIALRECEIVE, VALIDATEUARTPORT

    %   Author: Frey, Jed
    %   28-Sep-2026; Last revision: 28-Sep-2026

    properties (Nontunable)
        Port (1,1) {mustBeInteger, mustBeNonnegative} = 0
        BaudRate (1,1) {mustBeInteger, mustBePositive} = 9600
        SampleTime (1,1) double = -1
    end

    methods
        function obj = SerialTransmit(varargin)
        %SERIALTRANSMIT - Construct a SerialTransmit System object.
        %   Calls coder.allowpcode("plain") and setProperties for nontunable
        %   Port, BaudRate, and SampleTime.
        %
        %   Syntax:
        %       obj = SerialTransmit()
        %       obj = SerialTransmit(Name=value)
        %
        %   Inputs:
        %       varargin - Optional name-value pairs for nontunable properties.
        %
        %   Outputs:
        %       obj - Constructed SerialTransmit instance.
        %
        %   Example:
        %       obj = arduinopio.blocks.common.SerialTransmit(Port=0);
        %
        %   See also: SETUPIMPL, STEPIMPL

            coder.allowpcode("plain");
            setProperties(obj, nargin, varargin{:});
        end
    end

    methods (Access = protected)
        function validatePropertiesImpl(obj)
        %VALIDATEPROPERTIESIMPL - Validate the UART port number.
        %   Calls arduinopio.validateUartPort(obj.Port).
        %
        %   Syntax:
        %       validatePropertiesImpl(obj)
        %
        %   Inputs:
        %       obj - SerialTransmit System object.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       % Invoked by the System object framework during setup.
        %
        %   See also: VALIDATEUARTPORT

            arduinopio.validateUartPort(obj.Port);
        end

        function setupImpl(obj)
        %SETUPIMPL - Open the UART at the configured baud rate on RTW.
        %   When coder.target is "Rtw", includes arduinopio_uart.h and calls
        %   arduinopioUartSetup(uint8(Port), uint32(BaudRate)). No host setup.
        %
        %   Syntax:
        %       setupImpl(obj)
        %
        %   Inputs:
        %       obj - SerialTransmit System object.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       % Invoked once before stepImpl during simulation or codegen.
        %
        %   See also: STEPIMPL, ARDUINOPIOUARTSETUP

            if coder.target("Rtw")
                coder.cinclude("arduinopio_uart.h");
                coder.ceval("arduinopioUartSetup", uint8(obj.Port), uint32(obj.BaudRate));
            end
        end

        function stepImpl(obj, u)
        %STEPIMPL - Write input bytes to the UART on RTW.
        %   Casts u(:) to uint8 and calls arduinopioUartWrite with Port,
        %   coder.rref(data), and numel(data). Host performs no write.
        %
        %   Syntax:
        %       stepImpl(obj, u)
        %
        %   Inputs:
        %       obj - SerialTransmit System object.
        %       u   - Bytes to transmit; reshaped to a uint8 column.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       % Driven each sample by the Simulink System block.
        %
        %   See also: SETUPIMPL, ARDUINOPIOUARTWRITE

            if coder.target("Rtw")
                data = uint8(u(:));
                coder.ceval("arduinopioUartWrite", uint8(obj.Port), coder.rref(data), uint8(numel(data)));
            end
        end

        function num = getNumInputsImpl(~)
        %GETNUMINPUTSIMPL - Report one input port for transmit data.
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
        %GETNUMOUTPUTSIMPL - Report zero output ports for serial transmit.
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

        function icon = getIconImpl(~)
        %GETICONIMPL - Block icon label for Serial Transmit.
        %   Returns the string "Serial Transmit".
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

            icon = "Serial Transmit";
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
        %       obj - SerialTransmit System object.
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
        %GETDESCRIPTIVENAME - Return the codegen display name for Serial Transmit.
        %   Returns the string "Arduino PIO Serial Transmit".
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

            name = "Arduino PIO Serial Transmit";
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
        %UPDATEBUILDINFO - Register arduinopio_uart.cpp for codegen.
        %   Calls arduinopio.updateDriverBuildInfo with source
        %   "arduinopio_uart.cpp".
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

            arduinopio.updateDriverBuildInfo(buildInfo, context, "arduinopio_uart.cpp");
        end
    end
end
