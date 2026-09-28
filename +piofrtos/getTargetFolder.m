function targetFolder = getTargetFolder()
%getTargetFolder Return the folder that stores STF, TMF, and hook files.
    targetFolder = fullfile(piofrtos.getTargetRoot(), "piofrtos");
end
