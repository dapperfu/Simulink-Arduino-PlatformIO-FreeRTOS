function arduinopio_serial_receive(block)
%ARDUINOPIO_SERIAL_RECEIVE - Level-2 MATLAB S-function for UART receive.
%   Entry point for the Serial Receive library block. Delegates to setup.
%   Dialog parameters are Port, BaudRate, DataLength, and SampleTime. Outputs
%   are a DataLength-by-1 uint8 vector and a boolean status. Host Outputs emit
%   zeros and false. WriteRTW records Port, BaudRate, and DataLength for TLC.
%
%   Syntax:
%       arduinopio_serial_receive(block)
%
%   Inputs:
%       block - Level-2 MATLAB S-Function block handle
%
%   Outputs:
%       none
%
%   Example:
%       % Invoked by Simulink when FunctionName is arduinopio_serial_receive
%
%   Other m-files required: arduinopio.sfcn.setSampleTime,
%       arduinopio.sfcn.applyCommonIoOptions, arduinopio.sfcn.writeRtwScalar,
%       arduinopio.validateUartPort
%   Subfunctions: setup, checkParameters, outputs, writeRtw
%   MAT-files required: none
%
%   See also: ARDUINOPIO_SERIAL_TRANSMIT, RTWMAKECFG

%   Author: Frey, Jed
%   28-Sep-2026; Last revision: 28-Sep-2026

%------------- BEGIN CODE --------------

    setup(block);
end

function setup(block)
%SETUP - Configure dual outputs, sample time, and methods for serial receive.
%   Sets four nontunable dialog parameters. Output 1 is uint8 (DatatypeID 3)
%   sized DataLength-by-1 (default 1 if dialog data unavailable during library
%   creation). Output 2 is boolean status. Sample time uses dialog index 4.
%   Registers CheckParameters, Outputs, and WriteRTW after applyCommonIoOptions.
%
%   Syntax:
%       setup(block)
%
%   Inputs:
%       block - Level-2 MATLAB S-Function block handle
%
%   Outputs:
%       none
%
%   Example:
%       setup(block);
%
%   See also: CHECKPARAMETERS, OUTPUTS, WRITERTW

    block.NumDialogPrms = 4;
    block.DialogPrmsTunable = {'Nontunable', 'Nontunable', 'Nontunable', 'Nontunable'};
    block.NumInputPorts = 0;
    block.NumOutputPorts = 2;

    dataLength = 1;
    try
        dataLength = max(1, round(double(block.DialogPrm(3).Data)));
    catch
        % Dialog parameters are not available while the library block is created.
    end
    block.OutputPort(1).Dimensions = [dataLength, 1];
    block.OutputPort(1).DatatypeID = 3;
    block.OutputPort(1).Complexity = "Real";
    block.OutputPort(1).SamplingMode = "Sample";

    block.OutputPort(2).Dimensions = 1;
    block.OutputPort(2).DatatypeID = 8;
    block.OutputPort(2).Complexity = "Real";
    block.OutputPort(2).SamplingMode = "Sample";

    arduinopio.sfcn.setSampleTime(block, 4);
    arduinopio.sfcn.applyCommonIoOptions(block);

    block.RegBlockMethod("CheckParameters", @checkParameters);
    block.RegBlockMethod("Outputs", @outputs);
    block.RegBlockMethod("WriteRTW", @writeRtw);
end

function checkParameters(block)
%CHECKPARAMETERS - Validate Port, BaudRate, and DataLength dialog values.
%   Requires Port as a finite scalar, BaudRate a positive finite scalar, and
%   DataLength a finite scalar >= 1, then calls arduinopio.validateUartPort.
%
%   Syntax:
%       checkParameters(block)
%
%   Inputs:
%       block - Level-2 MATLAB S-Function block handle
%
%   Outputs:
%       none
%
%   Example:
%       checkParameters(block);
%
%   See also: SETUP, OUTPUTS

    port = block.DialogPrm(1).Data;
    baudRate = block.DialogPrm(2).Data;
    dataLength = block.DialogPrm(3).Data;
    if ~(isscalar(port) && isnumeric(port) && isfinite(port))
        error("arduinopio:InvalidDialog", "Port must be a real scalar.");
    end
    if ~(isscalar(baudRate) && isnumeric(baudRate) && isfinite(baudRate) && baudRate > 0)
        error("arduinopio:InvalidDialog", "BaudRate must be a positive scalar.");
    end
    if ~(isscalar(dataLength) && isnumeric(dataLength) && isfinite(dataLength) && dataLength >= 1)
        error("arduinopio:InvalidDialog", "DataLength must be a positive integer.");
    end
    arduinopio.validateUartPort(port);
end

function outputs(block)
%OUTPUTS - Produce zero bytes and false status during host simulation.
%   Sizes the uint8 data vector from DataLength (dialog parameter 3) and writes
%   zeros plus false status. No UART read occurs on the host.
%
%   Syntax:
%       outputs(block)
%
%   Inputs:
%       block - Level-2 MATLAB S-Function block handle
%
%   Outputs:
%       none
%
%   Example:
%       outputs(block);
%
%   See also: CHECKPARAMETERS, WRITERTW

    dataLength = max(1, round(double(block.DialogPrm(3).Data)));
    block.OutputPort(1).Data = zeros(dataLength, 1, "uint8");
    block.OutputPort(2).Data = false;
end

function writeRtw(block)
%WRITERTW - Emit Port, BaudRate, and DataLength for TLC UART receive.
%   Writes dialog parameters 1-3 as RTW scalars consumed by the serial receive
%   TLC path and linked uart driver sources from rtwmakecfg.
%
%   Syntax:
%       writeRtw(block)
%
%   Inputs:
%       block - Level-2 MATLAB S-Function block handle
%
%   Outputs:
%       none
%
%   Example:
%       writeRtw(block);
%
%   See also: SETUP, RTWMAKECFG

    arduinopio.sfcn.writeRtwScalar(block, "Port", block.DialogPrm(1).Data);
    arduinopio.sfcn.writeRtwScalar(block, "BaudRate", block.DialogPrm(2).Data);
    arduinopio.sfcn.writeRtwScalar(block, "DataLength", block.DialogPrm(3).Data);
end
