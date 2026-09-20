function rootDir = getRootFolder()
%getRootFolder Return the repository root folder.

    thisFile = mfilename("fullpath");
    packageDir = fileparts(thisFile);
    matlabDir = fileparts(packageDir);
    rootDir = fileparts(matlabDir);
end
