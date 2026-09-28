function arduinopio_digital_output(block)
%ARDUINOPIO_DIGITAL_OUTPUT - Level-2 MATLAB S-function for digitalWrite.
%   Entry point for the Digital Output library block. Delegates to setup.
%   Dialog parameters are Pin and SampleTime. Accepts a double scalar input with
%   direct feedthrough. Host Outputs is a no-op; WriteRTW records Pin so TLC
%   can inline a digital write on the target.
%
%   Syntax:
%       arduinopio_digital_output(block)
%
%   Inputs:
%       block - Level-2 MATLAB S-Function block handle
%
%   Outputs:
%       none
%
%   Example:
%       % Invoked by Simulink when FunctionName is arduinopio_digital_output
%
%   Other m-files required: arduinopio.sfcn.setSampleTime,
%       arduinopio.sfcn.applyCommonIoOptions, arduinopio.sfcn.writeRtwScalar,
%       arduinopio.validatePin
%   Subfunctions: setup, checkParameters, outputs, writeRtw
%   MAT-files required: none
%
%   See also: ARDUINOPIO_DIGITAL_INPUT, ARDUINOPIO_ANALOG_OUTPUT

%   Author: Frey, Jed
%   28-Sep-2026; Last revision: 28-Sep-2026

%------------- BEGIN CODE --------------

    setup(block);
end

function setup(block)
%SETUP - Configure double input, sample time, and methods for digital output.
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
%CHECKPARAMETERS - Validate Pin as a digital dialog value.
%   Requires Pin to be a finite numeric scalar, then calls
%   arduinopio.validatePin with mode "digital".
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
    arduinopio.validatePin(pin, "digital");
end

function outputs(~)
%OUTPUTS - No-op host simulation for digitalWrite.
%   Host simulation has no Arduino hardware. Code generation inlines a write
%   using the Pin RTW parameter from writeRtw.
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

    % Host simulation has no Arduino hardware. Code generation inlines a write.
end

function writeRtw(block)
%WRITERTW - Emit Pin RTW parameter for TLC digitalWrite code generation.
%   Writes dialog parameter 1 as scalar Pin via writeRtwScalar for the digital
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
