classdef (Sealed) SerialReceive < matlab.System & coder.ExternalDependency
    %SERIALRECEIVE - Read bytes from an Arduino hardware UART port.
    %   Sealed matlab.System plus coder.ExternalDependency. Uno uses Serial0 on
    %   pins 0 and 1. Nontunable Port defaults to 0, BaudRate to 9600,
    %   DataLength to 1, SampleTime to -1 (inherited). validatePropertiesImpl
    %   calls arduinopio.validateUartPort. On RTW, setupImpl includes
    %   arduinopio_uart.h and calls arduinopioUartSetup(Port, BaudRate).
    %   stepImpl returns DataLength-by-1 uint8 data and logical status; on RTW
    %   status is true when arduinopioUartRead returns a nonzero count. Host
    %   returns zeros and false. updateBuildInfo adds arduinopio_uart.cpp.
    %   The Common library block uses Level-2 MATLAB S-function
    %   arduinopio_serial_receive instead of this System object.
    %
    %   Syntax:
    %       obj = arduinopio.blocks.common.SerialReceive
    %       obj = arduinopio.blocks.common.SerialReceive(Name=value)
    %
    %   Inputs:
    %       Port       - (1,1) nonnegative integer UART port. Default: 0.
    %       BaudRate   - (1,1) positive integer baud rate. Default: 9600.
    %       DataLength - (1,1) positive integer bytes to read. Default: 1.
    %       SampleTime - (1,1) double. Default: -1 (inherited).
    %
    %   Outputs:
    %       obj    - SerialReceive System object.
    %       data   - stepImpl output 1: DataLength-by-1 uint8 bytes.
    %       status - stepImpl output 2: logical true if any bytes were read.
    %
    %   Example:
    %       obj = arduinopio.blocks.common.SerialReceive(BaudRate=115200);
    %
    %   Other m-files required: arduinopio.validateUartPort,
    %       arduinopio.updateDriverBuildInfo
    %   Subfunctions: none
    %   MAT-files required: none
    %
    %   See also: SERIALTRANSMIT, VALIDATEUARTPORT

    %   Author: Frey, Jed
    %   28-Sep-2026; Last revision: 28-Sep-2026

    properties (Nontunable)
        Port (1,1) {mustBeInteger, mustBeNonnegative} = 0
        BaudRate (1,1) {mustBeInteger, mustBePositive} = 9600
        DataLength (1,1) {mustBeInteger, mustBePositive} = 1
        SampleTime (1,1) double = -1
    end

    methods
        function obj = SerialReceive(varargin)
        %SERIALRECEIVE - Construct a SerialReceive System object.
        %   Calls coder.allowpcode("plain") and setProperties for nontunable
        %   Port, BaudRate, DataLength, and SampleTime.
        %
        %   Syntax:
        %       obj = SerialReceive()
        %       obj = SerialReceive(Name=value)
        %
        %   Inputs:
        %       varargin - Optional name-value pairs for nontunable properties.
        %
        %   Outputs:
        %       obj - Constructed SerialReceive instance.
        %
        %   Example:
        %       obj = arduinopio.blocks.common.SerialReceive(Port=0);
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
        %       obj - SerialReceive System object.
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
        %       obj - SerialReceive System object.
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

        function [data, status] = stepImpl(obj)
        %STEPIMPL - Read up to DataLength UART bytes and report status.
        %   Preallocates zeros(DataLength,1,"uint8") and status false. On RTW
        %   calls arduinopioUartRead; status is (count > 0). Host returns zeros
        %   and false.
        %
        %   Syntax:
        %       [data, status] = stepImpl(obj)
        %
        %   Inputs:
        %       obj - SerialReceive System object.
        %
        %   Outputs:
        %       data   - DataLength-by-1 uint8 receive buffer.
        %       status - Logical true when at least one byte was read on RTW.
        %
        %   Example:
        %       % Driven each sample by the Simulink System block.
        %
        %   See also: SETUPIMPL, ARDUINOPIOUARTREAD

            data = zeros(obj.DataLength, 1, "uint8");
            status = false;
            if coder.target("Rtw")
                count = uint8(0);
                count = coder.ceval("arduinopioUartRead", uint8(obj.Port), coder.wref(data), uint8(obj.DataLength));
                status = (count > 0);
            end
        end

        function num = getNumInputsImpl(~)
        %GETNUMINPUTSIMPL - Report zero input ports for serial receive.
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
        %GETNUMOUTPUTSIMPL - Report two outputs: data and status.
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

        function [sz1, sz2] = getOutputSizeImpl(obj)
        %GETOUTPUTSIZEIMPL - Data is DataLength-by-1; status is 1-by-1.
        %   Returns sz1 = [obj.DataLength, 1] and sz2 = [1, 1].
        %
        %   Syntax:
        %       [sz1, sz2] = getOutputSizeImpl(obj)
        %
        %   Inputs:
        %       obj - SerialReceive System object.
        %
        %   Outputs:
        %       sz1 - Size of data ([DataLength, 1]).
        %       sz2 - Size of status ([1, 1]).
        %
        %   Example:
        %       % Queried during model compilation.
        %
        %   See also: GETOUTPUTDATATYPEIMPL

            sz1 = [obj.DataLength, 1];
            sz2 = [1, 1];
        end

        function [dt1, dt2] = getOutputDataTypeImpl(~)
        %GETOUTPUTDATATYPEIMPL - Data is uint8; status is logical.
        %   Returns dt1 = "uint8" and dt2 = "logical".
        %
        %   Syntax:
        %       [dt1, dt2] = getOutputDataTypeImpl(obj)
        %
        %   Inputs:
        %       ~ - Unused System object.
        %
        %   Outputs:
        %       dt1 - Data type of data ("uint8").
        %       dt2 - Data type of status ("logical").
        %
        %   Example:
        %       % Queried during model compilation.
        %
        %   See also: GETOUTPUTSIZEIMPL

            dt1 = "uint8";
            dt2 = "logical";
        end

        function [c1, c2] = isOutputComplexImpl(~)
        %ISOUTPUTCOMPLEXIMPL - Both serial receive outputs are real-valued.
        %   Returns c1 = false and c2 = false.
        %
        %   Syntax:
        %       [c1, c2] = isOutputComplexImpl(obj)
        %
        %   Inputs:
        %       ~ - Unused System object.
        %
        %   Outputs:
        %       c1 - Complexity of data (false).
        %       c2 - Complexity of status (false).
        %
        %   Example:
        %       % Queried during model compilation.
        %
        %   See also: ISOUTPUTFIXEDSIZEIMPL

            c1 = false;
            c2 = false;
        end

        function [f1, f2] = isOutputFixedSizeImpl(~)
        %ISOUTPUTFIXEDSIZEIMPL - Both serial receive outputs have fixed size.
        %   Returns f1 = true and f2 = true.
        %
        %   Syntax:
        %       [f1, f2] = isOutputFixedSizeImpl(obj)
        %
        %   Inputs:
        %       ~ - Unused System object.
        %
        %   Outputs:
        %       f1 - Fixed-size flag for data (true).
        %       f2 - Fixed-size flag for status (true).
        %
        %   Example:
        %       % Queried during model compilation.
        %
        %   See also: ISOUTPUTCOMPLEXIMPL

            f1 = true;
            f2 = true;
        end

        function icon = getIconImpl(~)
        %GETICONIMPL - Block icon label for Serial Receive.
        %   Returns the string "Serial Receive".
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

            icon = "Serial Receive";
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
        %       obj - SerialReceive System object.
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
        %GETDESCRIPTIVENAME - Return the codegen display name for Serial Receive.
        %   Returns the string "Arduino PIO Serial Receive".
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

            name = "Arduino PIO Serial Receive";
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
