function arduinopio_analog_output(block)
%arduinopio_analog_output Level-2 MATLAB S-function for analogWrite / PWM output.
    setup(block);
end

function setup(block)
    block.NumDialogPrms = 2;
    block.DialogPrmsTunable = {'Nontunable', 'Nontunable'};
    block.NumInputPorts = 1;
    block.NumOutputPorts = 0;

    block.InputPort(1).Dimensions = 1;
    block.InputPort(1).DatatypeID = 0;
    block.InputPort(1).Complexity = "Real";
    block.InputPort(1).DirectFeedthrough = true;
    block.InputPort(1).SamplingMode = "Sample";

    arduinopio.sfcn.setSampleTime(block, 2);
    arduinopio.sfcn.applyCommonIoOptions(block);

    block.RegBlockMethod("CheckParameters", @checkParameters);
    block.RegBlockMethod("Outputs", @outputs);
    block.RegBlockMethod("WriteRTW", @writeRtw);
end

function checkParameters(block)
    pin = block.DialogPrm(1).Data;
    if ~(isscalar(pin) && isnumeric(pin) && isfinite(pin))
        error("arduinopio:InvalidDialog", "Pin must be a real scalar.");
    end
    arduinopio.validatePin(pin, "pwm");
end

function outputs(~)
    % Host simulation has no Arduino hardware. Code generation inlines analogWrite.
end

function writeRtw(block)
    arduinopio.sfcn.writeRtwScalar(block, "Pin", block.DialogPrm(1).Data);
end
