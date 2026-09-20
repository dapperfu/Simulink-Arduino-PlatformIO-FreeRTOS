function arduinopio_serial_transmit(block)
%arduinopio_serial_transmit Level-2 MATLAB S-function for UART transmit.
    setup(block);
end

function setup(block)
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
    block.InputPort(port).Dimensions = dimsInfo;
end

function outputs(~)
    % Host simulation has no UART. Code generation inlines Serial.write.
end

function writeRtw(block)
    arduinopio.sfcn.writeRtwScalar(block, "Port", block.DialogPrm(1).Data);
    arduinopio.sfcn.writeRtwScalar(block, "BaudRate", block.DialogPrm(2).Data);
end
