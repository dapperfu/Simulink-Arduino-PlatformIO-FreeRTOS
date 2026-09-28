function arduinopio_digital_input(block)
%arduinopio_digital_input Level-2 MATLAB S-function for pinMode / digitalRead.
    setup(block);
end

function setup(block)
    block.NumDialogPrms = 4;
    block.DialogPrmsTunable = {'Nontunable', 'Nontunable', 'Nontunable', 'Nontunable'};
    block.NumInputPorts = 0;
    block.NumOutputPorts = 1;

    block.OutputPort(1).Dimensions = 1;
    block.OutputPort(1).DatatypeID = 8;
    block.OutputPort(1).Complexity = "Real";
    block.OutputPort(1).SamplingMode = "Sample";

    arduinopio.sfcn.setSampleTime(block, 3);
    arduinopio.sfcn.applyCommonIoOptions(block);

    block.RegBlockMethod("CheckParameters", @checkParameters);
    block.RegBlockMethod("Outputs", @outputs);
    block.RegBlockMethod("WriteRTW", @writeRtw);
end

function checkParameters(block)
    pin = block.DialogPrm(1).Data;
    pinPull = block.DialogPrm(2).Data;
    simValue = block.DialogPrm(4).Data;
    if ~(isscalar(pin) && isnumeric(pin) && isfinite(pin))
        error("arduinopio:InvalidDialog", "Pin must be a real scalar.");
    end
    if ~(isscalar(simValue) && isnumeric(simValue) && isfinite(simValue))
        error("arduinopio:InvalidDialog", "SimValue must be a real scalar.");
    end
    arduinopio.validatePin(pin, "digital");
    arduinopio.validatePinPull(pinPull);
end

function outputs(block)
    simValue = block.DialogPrm(4).Data;
    block.OutputPort(1).Data = logical(simValue ~= 0);
end

function writeRtw(block)
    arduinopio.sfcn.writeRtwScalar(block, "Pin", block.DialogPrm(1).Data);
    arduinopio.sfcn.writeRtwScalar(block, "PinPull", arduinopio.pinPullIndex(block.DialogPrm(2).Data));
end
