function arduinopio_digital_input(block)
%arduinopio_digital_input Level-2 MATLAB S-function for a digital input pin.
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
    pullup = block.DialogPrm(2).Data;
    simValue = block.DialogPrm(4).Data;
    if ~(isscalar(pin) && isnumeric(pin) && isfinite(pin))
        error("arduinopio:InvalidDialog", "Pin must be a real scalar.");
    end
    if ~(isscalar(pullup) && isnumeric(pullup))
        error("arduinopio:InvalidDialog", "Pullup must be 0 or 1.");
    end
    if ~(isscalar(simValue) && isnumeric(simValue) && isfinite(simValue))
        error("arduinopio:InvalidDialog", "SimValue must be a real scalar.");
    end
    arduinopio.validatePin(pin, "digital");
end

function outputs(block)
    simValue = block.DialogPrm(4).Data;
    block.OutputPort(1).Data = logical(simValue ~= 0);
end

function writeRtw(block)
    arduinopio.sfcn.writeRtwScalar(block, "Pin", block.DialogPrm(1).Data);
    arduinopio.sfcn.writeRtwScalar(block, "Pullup", block.DialogPrm(2).Data ~= 0);
end
