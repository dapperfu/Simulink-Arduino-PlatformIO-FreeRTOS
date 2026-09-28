function rootDir = getRootFolder()
%GETROOTFOLDER - Return the repository root folder.
%   Resolves this file under matlab/+arduinopio and walks up two directories
%   (package folder -> matlab -> repo root). Package path: arduinopio.getRootFolder.
%
%   Syntax:
%       rootDir = arduinopio.getRootFolder()
%
%   Inputs:
%       none
%
%   Outputs:
%       rootDir - char/string path. Absolute path to the repository root.
%
%   Example:
%       root = arduinopio.getRootFolder();
%
%   Other m-files required: none
%   Subfunctions: none
%   MAT-files required: none
%
%   See also: LISTLIBRARYBLOCKS, UPDATEDRIVERBUILDINFO

%   Author: Frey, Jed
%   28-Sep-2026; Last revision: 28-Sep-2026

%------------- BEGIN CODE --------------
    thisFile = mfilename("fullpath");
    packageDir = fileparts(thisFile);
    matlabDir = fileparts(packageDir);
    rootDir = fileparts(matlabDir);
end
