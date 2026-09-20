function arduinopio_serial_receive(block)
%arduinopio_serial_receive Level-2 MATLAB S-function for UART receive.
    setup(block);
end

function setup(block)
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
    dataLength = max(1, round(double(block.DialogPrm(3).Data)));
    block.OutputPort(1).Data = zeros(dataLength, 1, "uint8");
    block.OutputPort(2).Data = false;
end

function writeRtw(block)
    arduinopio.sfcn.writeRtwScalar(block, "Port", block.DialogPrm(1).Data);
    arduinopio.sfcn.writeRtwScalar(block, "BaudRate", block.DialogPrm(2).Data);
    arduinopio.sfcn.writeRtwScalar(block, "DataLength", block.DialogPrm(3).Data);
end
