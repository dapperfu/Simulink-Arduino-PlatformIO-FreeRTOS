function writeRtwScalar(block, name, value)
%WRITERTWSCALAR - Write a numeric dialog value into the generated model.rtw record.
%   Calls block.WriteRTWParam with matrix type, name as char, and value as
%   double. Package path: arduinopio.sfcn.writeRtwScalar.
%
%   Syntax:
%       arduinopio.sfcn.writeRtwScalar(block, name, value)
%
%   Inputs:
%       block - Level-2 MATLAB S-function block object with WriteRTWParam.
%       name - (1,1) string. RTW parameter name written into model.rtw.
%       value - (1,1) numeric. Scalar stored as double.
%
%   Outputs:
%       none
%
%   Example:
%       % From an S-function WriteRTW method:
%       % arduinopio.sfcn.writeRtwScalar(block, "Pin", pin);
%
%   Other m-files required: none
%   Subfunctions: none
%   MAT-files required: none
%
%   See also: SETSAMPLETIME, APPLYCOMMONIOOPTIONS

%   Author: Frey, Jed
%   28-Sep-2026; Last revision: 28-Sep-2026

%------------- BEGIN CODE --------------
    arguments
        block
        name (1,1) string
        value (1,1) {mustBeNumeric}
    end

    block.WriteRTWParam('matrix', char(name), double(value));
end
