function buildDir = getBuildDirectory(modelName)
%GETBUILDDIRECTORY - Return the code generation folder for a model.
%   Wraps RTW.getBuildDir for the piofrtos package and returns the
%   BuildDirectory field as a string. Used by writeGeneratedFiles and related
%   helpers to locate the PlatformIO project folder under the model RTW
%   build directory (typically ending in _piofrtos_rtw).
%
%   Syntax:
%       buildDir = piofrtos.getBuildDirectory(modelName)
%
%   Inputs:
%       modelName - (1,1) string name of a Simulink model known to RTW.
%           Invalid models raise whatever error RTW.getBuildDir produces.
%
%   Outputs:
%       buildDir - string absolute path of the model's code generation folder.
%
%   Example:
%       % Resolve where generated PlatformIO files will be written.
%       buildDir = piofrtos.getBuildDirectory("blink");
%
%   Other m-files required: none
%   Subfunctions: none
%   MAT-files required: none
%
%   See also: WRITEGENERATEDFILES, GETMODELOPTIONS

%   Author: Frey, Jed
%   28-Sep-2026; Last revision: 28-Sep-2026

%------------- BEGIN CODE --------------
    arguments
        modelName (1,1) string
    end

    buildInfo = RTW.getBuildDir(modelName);
    buildDir = string(buildInfo.BuildDirectory);
end
