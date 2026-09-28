function rootFolder = getTargetRoot()
%GETTARGETROOT - Return the repository root that contains this target.
%   Locates the piofrtos package folder via mfilename("fullpath") and returns
%   its parent directory as a string. That root holds the +piofrtos package
%   and the target folder used by getTargetFolder for STF and TMF files.
%
%   Syntax:
%       rootFolder = piofrtos.getTargetRoot()
%
%   Inputs:
%       none
%
%   Outputs:
%       rootFolder - string path to the repository root (parent of +piofrtos).
%
%   Example:
%       % Resolve the checkout that owns the PlatformIO FreeRTOS target.
%       rootFolder = piofrtos.getTargetRoot();
%
%   Other m-files required: none
%   Subfunctions: none
%   MAT-files required: none
%
%   See also: GETTARGETFOLDER, GENERATETARGETFILES

%   Author: Frey, Jed
%   28-Sep-2026; Last revision: 28-Sep-2026

%------------- BEGIN CODE --------------
    packageFolder = fileparts(mfilename("fullpath"));
    rootFolder = string(fileparts(packageFolder));
end
