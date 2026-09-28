function arduinopio_analog_input(block)
%ARDUINOPIO_ANALOG_INPUT - Level-2 MATLAB S-function for analogRead.
%   Entry point for the Analog Input library block. Delegates to setup.
%   Dialog parameters are Pin, SampleTime, and SimValue. Host Outputs clamp
%   SimValue to 0-1023 as uint16. WriteRTW records Pin for TLC analogRead.
%
%   Syntax:
%       arduinopio_analog_input(block)
%
%   Inputs:
%       block - Level-2 MATLAB S-Function block handle
%
%   Outputs:
%       none
%
%   Example:
%       % Invoked by Simulink when FunctionName is arduinopio_analog_input
%
%   Other m-files required: arduinopio.sfcn.setSampleTime,
%       arduinopio.sfcn.applyCommonIoOptions, arduinopio.sfcn.writeRtwScalar,
%       arduinopio.validatePin
%   Subfunctions: setup, checkParameters, outputs, writeRtw
%   MAT-files required: none
%
%   See also: ARDUINOPIO_ANALOG_OUTPUT, ARDUINOPIO_DIGITAL_INPUT

%   Author: Frey, Jed
%   28-Sep-2026; Last revision: 28-Sep-2026

%------------- BEGIN CODE --------------

    setup(block);
end

function setup(block)
%SETUP - Configure ports, sample time, and methods for analog input.
%   Sets three nontunable dialog parameters (Pin, SampleTime, SimValue), zero
%   inputs, and one uint16 scalar output (DatatypeID 5). Sample time uses dialog
%   parameter index 2. Registers CheckParameters, Outputs, and WriteRTW after
%   applyCommonIoOptions.
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
%CHECKPARAMETERS - Validate Pin and SimValue for analog input.
%   Requires both dialog values to be finite numeric scalars, then validates Pin
%   with arduinopio.validatePin using mode "analog".
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
%OUTPUTS - Emit saturated ADC counts from SimValue on the host.
%   Rounds SimValue (dialog parameter 3), clamps to 0 through 1023, and writes
%   uint16 to OutputPort(1). Mirrors a 10-bit ADC without calling hardware.
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

    simValue = block.DialogPrm(3).Data;
    analogMax = 1023;
    saturated = min(max(round(double(simValue)), 0), analogMax);
    block.OutputPort(1).Data = uint16(saturated);
end

function writeRtw(block)
%WRITERTW - Emit Pin RTW parameter for TLC analogRead code generation.
%   Writes dialog parameter 1 as scalar Pin via writeRtwScalar for the analog
%   input TLC implementation.
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
end
