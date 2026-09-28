function arduinopio_analog_input(block)
%arduinopio_analog_input Level-2 MATLAB S-function for analogRead.
    setup(block);
end

function setup(block)
    block.NumDialogPrms = 3;
    block.DialogPrmsTunable = {'Nontunable', 'Nontunable', 'Nontunable'};
    block.NumInputPorts = 0;
    block.NumOutputPorts = 1;

    block.OutputPort(1).Dimensions = 1;
    block.OutputPort(1).DatatypeID = 5;
    block.OutputPort(1).Complexity = "Real";
    block.OutputPort(1).SamplingMode = "Sample";

    arduinopio.sfcn.setSampleTime(block, 2);
    arduinopio.sfcn.applyCommonIoOptions(block);

    block.RegBlockMethod("CheckParameters", @checkParameters);
    block.RegBlockMethod("Outputs", @outputs);
    block.RegBlockMethod("WriteRTW", @writeRtw);
end

function checkParameters(block)
    pin = block.DialogPrm(1).Data;
    simValue = block.DialogPrm(3).Data;
    if ~(isscalar(pin) && isnumeric(pin) && isfinite(pin))
        error("arduinopio:InvalidDialog", "Pin must be a real scalar.");
    end
    if ~(isscalar(simValue) && isnumeric(simValue) && isfinite(simValue))
        error("arduinopio:InvalidDialog", "SimValue must be a real scalar.");
    end
    arduinopio.validatePin(pin, "analog");
end

function outputs(block)
    simValue = block.DialogPrm(3).Data;
    analogMax = 1023;
    saturated = min(max(round(double(simValue)), 0), analogMax);
    block.OutputPort(1).Data = uint16(saturated);
end

function writeRtw(block)
    arduinopio.sfcn.writeRtwScalar(block, "Pin", block.DialogPrm(1).Data);
end
