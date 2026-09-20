function applyCommonIoOptions(block)
%applyCommonIoOptions Set Level-2 MATLAB S-function options used by I/O blocks.
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
