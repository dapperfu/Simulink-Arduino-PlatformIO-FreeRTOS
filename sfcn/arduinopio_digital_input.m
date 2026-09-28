function arduinopio_digital_input(block)
%ARDUINOPIO_DIGITAL_INPUT - Level-2 MATLAB S-function for digitalRead.
%   Entry point for the Digital Input library block. Delegates to setup to
%   register ports, sample time, and methods. Dialog parameters are Pin,
%   PinPull, SampleTime, and SimValue. Host Outputs emit SimValue as boolean.
%   WriteRTW records Pin and PinPull for TLC/codegen digitalRead paths.
%
%   Syntax:
%       arduinopio_digital_input(block)
%
%   Inputs:
%       block - Level-2 MATLAB S-Function block handle
%
%   Outputs:
%       none
%
%   Example:
%       % Invoked by Simulink when FunctionName is arduinopio_digital_input
%
%   Other m-files required: arduinopio.sfcn.setSampleTime,
%       arduinopio.sfcn.applyCommonIoOptions, arduinopio.sfcn.writeRtwScalar,
%       arduinopio.validatePin, arduinopio.validatePinPull,
%       arduinopio.pinPullIndex
%   Subfunctions: setup, checkParameters, outputs, writeRtw
%   MAT-files required: none
%
%   See also: ARDUINOPIO_DIGITAL_OUTPUT, ARDUINOPIO_ANALOG_INPUT

%   Author: Frey, Jed
%   28-Sep-2026; Last revision: 28-Sep-2026

%------------- BEGIN CODE --------------

    setup(block);
end

function setup(block)
%SETUP - Configure ports, sample time, and registered methods for digital in.
%   Sets four nontunable dialog parameters (Pin, PinPull, SampleTime, SimValue),
%   zero inputs, and one boolean scalar output (DatatypeID 8). Sample time comes
%   from dialog parameter index 3 via arduinopio.sfcn.setSampleTime. Registers
%   CheckParameters, Outputs, and WriteRTW after applyCommonIoOptions.
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
%CHECKPARAMETERS - Validate Pin, PinPull, and SimValue dialog values.
%   Requires Pin and SimValue to be finite numeric scalars, then calls
%   arduinopio.validatePin with "digital" and arduinopio.validatePinPull on
%   dialog parameter 2. SampleTime is not checked here.
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
%OUTPUTS - Drive the boolean output from SimValue during host simulation.
%   Reads dialog parameter 4 (SimValue) and writes logical(simValue ~= 0) to
%   OutputPort(1). No hardware digitalRead occurs on the host.
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

    simValue = block.DialogPrm(4).Data;
    block.OutputPort(1).Data = logical(simValue ~= 0);
end

function writeRtw(block)
%WRITERTW - Emit Pin and PinPull RTW parameters for TLC code generation.
%   Writes scalar Pin from dialog parameter 1 and PinPull as
%   arduinopio.pinPullIndex of dialog parameter 2 via writeRtwScalar so
%   generated code can configure the pin and call digitalRead.
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
%   See also: SETUP, ARDUINOPIO.SFCN.WRITERTWSCALAR

    arduinopio.sfcn.writeRtwScalar(block, "Pin", block.DialogPrm(1).Data);
    arduinopio.sfcn.writeRtwScalar(block, "PinPull", arduinopio.pinPullIndex(block.DialogPrm(2).Data));
end
