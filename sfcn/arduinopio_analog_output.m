function arduinopio_analog_output(block)
%ARDUINOPIO_ANALOG_OUTPUT - Level-2 MATLAB S-function for analogWrite / PWM.
%   Entry point for the Analog Output library block. Delegates to setup.
%   Dialog parameters are Pin and SampleTime. Accepts a double scalar input with
%   direct feedthrough. Host Outputs is a no-op; WriteRTW records Pin so TLC
%   can inline analogWrite on the target PWM pin.
%
%   Syntax:
%       arduinopio_analog_output(block)
%
%   Inputs:
%       block - Level-2 MATLAB S-Function block handle
%
%   Outputs:
%       none
%
%   Example:
%       % Invoked by Simulink when FunctionName is arduinopio_analog_output
%
%   Other m-files required: arduinopio.sfcn.setSampleTime,
%       arduinopio.sfcn.applyCommonIoOptions, arduinopio.sfcn.writeRtwScalar,
%       arduinopio.validatePin
%   Subfunctions: setup, checkParameters, outputs, writeRtw
%   MAT-files required: none
%
%   See also: ARDUINOPIO_ANALOG_INPUT, ARDUINOPIO_DIGITAL_OUTPUT

%   Author: Frey, Jed
%   28-Sep-2026; Last revision: 28-Sep-2026

%------------- BEGIN CODE --------------

    setup(block);
end

function setup(block)
%SETUP - Configure double input, sample time, and methods for PWM output.
%   Sets two nontunable dialog parameters (Pin, SampleTime), one double scalar
%   input (DatatypeID 0, direct feedthrough), and zero outputs. Sample time uses
%   dialog index 2. Registers CheckParameters, Outputs, and WriteRTW after
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
%CHECKPARAMETERS - Validate Pin as a PWM-capable dialog value.
%   Requires Pin to be a finite numeric scalar, then calls
%   arduinopio.validatePin with mode "pwm".
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
    if ~(isscalar(pin) && isnumeric(pin) && isfinite(pin))
        error("arduinopio:InvalidDialog", "Pin must be a real scalar.");
    end
    arduinopio.validatePin(pin, "pwm");
end

function outputs(~)
%OUTPUTS - No-op host simulation for analogWrite / PWM.
%   Host simulation has no Arduino hardware. Code generation inlines
%   analogWrite using the Pin RTW parameter from writeRtw.
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

    % Host simulation has no Arduino hardware. Code generation inlines analogWrite.
end

function writeRtw(block)
%WRITERTW - Emit Pin RTW parameter for TLC analogWrite code generation.
%   Writes dialog parameter 1 as scalar Pin via writeRtwScalar for the PWM
%   output TLC implementation.
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
