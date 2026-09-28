function rootFolder = getTargetRoot()
%getTargetRoot Return the repository root that contains this target.
    packageFolder = fileparts(mfilename("fullpath"));
    rootFolder = string(fileparts(packageFolder));
end
