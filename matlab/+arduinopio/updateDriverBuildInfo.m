function updateDriverBuildInfo(buildInfo, context, sourceFiles, libDeps)
%UPDATEDRIVERBUILDINFO - Add driver sources, includes, and library defines to codegen.
%   No-op unless context.isCodeGenTarget("rtw"). Adds src/drivers include path,
%   each sourceFiles entry via addSourceFiles, and each libDeps name via
%   addLibDep. SOURCEFILES and LIBDEPS are string arrays; LIBDEPS may be empty.
%   Package path: arduinopio.updateDriverBuildInfo.
%
%   Syntax:
%       arduinopio.updateDriverBuildInfo(buildInfo, context)
%       arduinopio.updateDriverBuildInfo(buildInfo, context, sourceFiles)
%       arduinopio.updateDriverBuildInfo(buildInfo, context, sourceFiles, libDeps)
%
%   Inputs:
%       buildInfo - RTW.BuildInfo (or compatible) object for the codegen build.
%       context - code-generation context with isCodeGenTarget method.
%       sourceFiles - (1,:) string. Driver .c/.cpp basenames. Default empty.
%       libDeps - (1,:) string. Library dependency names for addLibDep. Default
%           empty.
%
%   Outputs:
%       none
%
%   Example:
%       % From a System object updateBuildInfo method:
%       % arduinopio.updateDriverBuildInfo(buildInfo, context, "pwm_avr.cpp");
%
%   Other m-files required: arduinopio.getRootFolder, arduinopio.addLibDep
%   Subfunctions: none
%   MAT-files required: none
%
%   See also: ADDLIBDEP, GETROOTFOLDER, KNOWNLIBDEPS

%   Author: Frey, Jed
%   28-Sep-2026; Last revision: 28-Sep-2026

%------------- BEGIN CODE --------------
    arguments
        buildInfo
        context
        sourceFiles (1,:) string = string.empty(1, 0)
        libDeps (1,:) string = string.empty(1, 0)
    end

    if ~context.isCodeGenTarget("rtw")
        return
    end

    rootDir = arduinopio.getRootFolder();
    srcDir = fullfile(rootDir, "src", "drivers");
    addIncludePaths(buildInfo, srcDir);

    for i = 1:numel(sourceFiles)
        addSourceFiles(buildInfo, sourceFiles(i), srcDir);
    end

    for i = 1:numel(libDeps)
        arduinopio.addLibDep(buildInfo, libDeps(i));
    end
end
