function setSampleTime(block, parameterIndex)
%SETSAMPLETIME - Apply inherited (-1) or discrete sample time from a dialog.
%   Reads block.DialogPrm(parameterIndex).Data. Empty or -1 sets inherited
%   SampleTimes [-1, 0]. Positive finite scalars set [sampleTime, 0]. Missing
%   dialog data falls back to inherited. Invalid values error
%   arduinopio:InvalidSampleTime. Package path: arduinopio.sfcn.setSampleTime.
%
%   Syntax:
%       arduinopio.sfcn.setSampleTime(block, parameterIndex)
%
%   Inputs:
%       block - Level-2 MATLAB S-function block object with DialogPrm/SampleTimes.
%       parameterIndex - (1,1) positive integer. Dialog parameter index.
%
%   Outputs:
%       none
%
%   Example:
%       % From setup: arduinopio.sfcn.setSampleTime(block, 2);
%
%   Other m-files required: none
%   Subfunctions: none
%   MAT-files required: none
%
%   See also: WRITERTWSCALAR, APPLYCOMMONIOOPTIONS

%   Author: Frey, Jed
%   28-Sep-2026; Last revision: 28-Sep-2026

%------------- BEGIN CODE --------------
    arguments
        block
        parameterIndex (1,1) double {mustBeInteger, mustBePositive}
    end

    try
        sampleTime = block.DialogPrm(parameterIndex).Data;
    catch
        block.SampleTimes = [-1, 0];
        return
    end

    if isempty(sampleTime) || sampleTime == -1
        block.SampleTimes = [-1, 0];
    else
        if ~(isscalar(sampleTime) && isnumeric(sampleTime) && isfinite(sampleTime) && sampleTime > 0)
            error("arduinopio:InvalidSampleTime", ...
                "SampleTime must be -1 (inherited) or a positive finite scalar.");
        end
        block.SampleTimes = [double(sampleTime), 0];
    end
end
