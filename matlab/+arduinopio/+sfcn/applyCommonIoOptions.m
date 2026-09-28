function applyCommonIoOptions(block)
%APPLYCOMMONIOOPTIONS - Set Level-2 MATLAB S-function options used by I/O blocks.
%   Sets DefaultSimState compliance, enables TLC accel, disables sim viewing
%   device, and optionally sets OperatingPointCompliance when available.
%   Package path: arduinopio.sfcn.applyCommonIoOptions.
%
%   Syntax:
%       arduinopio.sfcn.applyCommonIoOptions(block)
%
%   Inputs:
%       block - Level-2 MATLAB S-function block object to configure.
%
%   Outputs:
%       none
%
%   Example:
%       % From setup: arduinopio.sfcn.applyCommonIoOptions(block);
%
%   Other m-files required: none
%   Subfunctions: none
%   MAT-files required: none
%
%   See also: SETSAMPLETIME, WRITERTWSCALAR

%   Author: Frey, Jed
%   28-Sep-2026; Last revision: 28-Sep-2026

%------------- BEGIN CODE --------------
    arguments
        block
    end

    block.SimStateCompliance = "DefaultSimState";
    block.SetAccelRunOnTLC(true);
    block.SetSimViewingDevice(false);
    try
        block.OperatingPointCompliance = "Default";
    catch
        % OperatingPointCompliance is not available in every MATLAB release.
    end
end
