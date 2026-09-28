function arduinopio_serial_transmit(block)
%ARDUINOPIO_SERIAL_TRANSMIT - Level-2 MATLAB S-function for UART transmit.
%   Entry point for the Serial Transmit library block. Delegates to setup.
%   Dialog parameters are Port, BaudRate, and SampleTime. Accepts a variable-
%   size uint8 input with direct feedthrough. Host Outputs is a no-op; WriteRTW
%   records Port and BaudRate so TLC can inline Serial.write on the target.
%
%   Syntax:
%       arduinopio_serial_transmit(block)
%
%   Inputs:
%       block - Level-2 MATLAB S-Function block handle
%
%   Outputs:
%       none
%
%   Example:
%       % Invoked by Simulink when FunctionName is arduinopio_serial_transmit
%
%   Other m-files required: arduinopio.sfcn.setSampleTime,
%       arduinopio.sfcn.applyCommonIoOptions, arduinopio.sfcn.writeRtwScalar,
%       arduinopio.validateUartPort
%   Subfunctions: setup, checkParameters, setInputPortDimensions, outputs,
%       writeRtw
%   MAT-files required: none
%
%   See also: ARDUINOPIO_SERIAL_RECEIVE, RTWMAKECFG

%   Author: Frey, Jed
%   28-Sep-2026; Last revision: 28-Sep-2026

%------------- BEGIN CODE --------------

    setup(block);
end

function setup(block)
%SETUP - Configure uint8 input, sample time, and methods for serial transmit.
%   Sets three nontunable dialog parameters, one dynamically sized uint8 input
%   (DatatypeID 3, Dimensions -1, direct feedthrough), and zero outputs. Sample
%   time uses dialog index 3. Registers CheckParameters, SetInputPortDimensions,
%   Outputs, and WriteRTW after applyCommonIoOptions.
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
%   See also: CHECKPARAMETERS, SETINPUTPORTDIMENSIONS, OUTPUTS, WRITERTW

    block.NumDialogPrms = 3;
    block.DialogPrmsTunable = {'Nontunable', 'Nontunable', 'Nontunable'};
    block.NumInputPorts = 1;
    block.NumOutputPorts = 0;

    block.InputPort(1).Dimensions = -1;
    block.InputPort(1).DatatypeID = 3;
    block.InputPort(1).Complexity = "Real";
    block.InputPort(1).DirectFeedthrough = true;
    block.InputPort(1).SamplingMode = "Sample";

    arduinopio.sfcn.setSampleTime(block, 3);
    arduinopio.sfcn.applyCommonIoOptions(block);

    block.RegBlockMethod("CheckParameters", @checkParameters);
    block.RegBlockMethod("SetInputPortDimensions", @setInputPortDimensions);
    block.RegBlockMethod("Outputs", @outputs);
    block.RegBlockMethod("WriteRTW", @writeRtw);
end

function checkParameters(block)
%CHECKPARAMETERS - Validate Port and BaudRate for serial transmit.
%   Requires Port as a finite scalar and BaudRate as a positive finite scalar,
%   then calls arduinopio.validateUartPort on Port.
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
%   See also: SETUP, SETINPUTPORTDIMENSIONS

    port = block.DialogPrm(1).Data;
    baudRate = block.DialogPrm(2).Data;
    if ~(isscalar(port) && isnumeric(port) && isfinite(port))
        error("arduinopio:InvalidDialog", "Port must be a real scalar.");
    end
    if ~(isscalar(baudRate) && isnumeric(baudRate) && isfinite(baudRate) && baudRate > 0)
        error("arduinopio:InvalidDialog", "BaudRate must be a positive scalar.");
    end
    arduinopio.validateUartPort(port);
end

function setInputPortDimensions(block, port, dimsInfo)
%SETINPUTPORTDIMENSIONS - Accept propagated dimensions on the uint8 input.
%   Assigns dimsInfo to InputPort(port).Dimensions so variable-length UART
%   payloads from upstream blocks propagate correctly.
%
%   Syntax:
%       setInputPortDimensions(block, port, dimsInfo)
%
%   Inputs:
%       block    - Level-2 MATLAB S-Function block handle
%       port     - Input port index
%       dimsInfo - Propagated dimension information
%
%   Outputs:
%       none
%
%   Example:
%       setInputPortDimensions(block, port, dimsInfo);
%
%   See also: SETUP, OUTPUTS

    block.InputPort(port).Dimensions = dimsInfo;
end

function outputs(~)
%OUTPUTS - No-op host simulation for UART transmit.
%   Host simulation has no UART hardware. Code generation inlines Serial.write
%   using RTW parameters from writeRtw. The block argument is unused.
%
%   Syntax:
%       outputs(block)
%
%   Inputs:
%       block - Unused Level-2 MATLAB S-Function block handle
%
%   Outputs:
%       none
%
%   Example:
%       outputs(block);
%
%   See also: WRITERTW

    % Host simulation has no UART. Code generation inlines Serial.write.
end

function writeRtw(block)
%WRITERTW - Emit Port and BaudRate for TLC UART transmit code generation.
%   Writes dialog parameters 1 and 2 as RTW scalars for the serial transmit TLC
%   path and uart driver sources listed by rtwmakecfg.
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
end
