function targetFolder = getTargetFolder()
%GETTARGETFOLDER - Return the folder that stores STF, TMF, and hook files.
%   Combines getTargetRoot with the "piofrtos" subfolder where generateTargetFiles
%   writes piofrtos.tlc and piofrtos.tmf. Used as the default targetFolder
%   argument for generateTargetFiles in the Arduino FreeRTOS PlatformIO target.
%
%   Syntax:
%       targetFolder = piofrtos.getTargetFolder()
%
%   Inputs:
%       none
%
%   Outputs:
%       targetFolder - string path fullfile(getTargetRoot(), "piofrtos").
%
%   Example:
%       % Locate where the system target file will be written.
%       targetFolder = piofrtos.getTargetFolder();
%
%   Other m-files required: getTargetRoot
%   Subfunctions: none
%   MAT-files required: none
%
%   See also: GETTARGETROOT, GENERATETARGETFILES

%   Author: Frey, Jed
%   28-Sep-2026; Last revision: 28-Sep-2026

%------------- BEGIN CODE --------------
    targetFolder = fullfile(piofrtos.getTargetRoot(), "piofrtos");
end
