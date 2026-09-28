function includeFlags = collectIncludeFlags(includePaths, options)
%COLLECTINCLUDEFLAGS - Convert include paths into PlatformIO -I build flags.
%   Builds the build_flags include list for platformio.ini in the piofrtos
%   Arduino FreeRTOS Simulink target. Always starts with -I. and appends the
%   MATLAB Simulink, extern, and RTW include folders under MatlabRoot. Expands
%   $(MATLAB_ROOT), $(ALT_MATLAB_ROOT), and optionally $(START_DIR). Paths that
%   still contain $( after expansion are skipped. Duplicate flags are removed
%   with unique(..., "stable").
%
%   Syntax:
%       includeFlags = piofrtos.collectIncludeFlags()
%       includeFlags = piofrtos.collectIncludeFlags(includePaths)
%       includeFlags = piofrtos.collectIncludeFlags(includePaths, MatlabRoot=mr)
%       includeFlags = piofrtos.collectIncludeFlags(includePaths, StartDir=sd)
%
%   Inputs:
%       includePaths - string array of include directories. Default: empty (0x1).
%           Backslashes are normalized to forward slashes; empty entries dropped.
%       options.MatlabRoot - (1,1) string MATLAB root. Default: string(matlabroot).
%       options.StartDir - (1,1) string start directory for $(START_DIR). Default: "".
%           When empty, $(START_DIR) tokens are left unchanged and may be skipped.
%
%   Outputs:
%       includeFlags - string array of -I flags, first element "-I.", then
%           -I"path" entries for each resolved include directory.
%
%   Example:
%       % Flags for default MATLAB include roots plus the current folder.
%       includeFlags = piofrtos.collectIncludeFlags();
%
%   Other m-files required: none
%   Subfunctions: expandMakeTokens
%   MAT-files required: none
%
%   See also: EMITPLATFORMIOINI, WRITEGENERATEDFILES

%   Author: Frey, Jed
%   28-Sep-2026; Last revision: 28-Sep-2026

%------------- BEGIN CODE --------------
    arguments
        includePaths string = string.empty(0, 1)
        options.MatlabRoot (1, 1) string = string(matlabroot)
        options.StartDir (1, 1) string = ""
    end

    matlabRoot = replace(options.MatlabRoot, "\", "/");
    startDir = replace(options.StartDir, "\", "/");
    defaultPaths = [
        matlabRoot + "/simulink/include"
        matlabRoot + "/extern/include"
        matlabRoot + "/rtw/c/src"
        ];
    includePaths = [includePaths(:); defaultPaths];
    includePaths = strip(replace(includePaths, "\", "/"));
    includePaths = includePaths(strlength(includePaths) > 0);

    includeFlags = "-I.";
    for pathIndex = 1:numel(includePaths)
        includePath = expandMakeTokens(includePaths(pathIndex), matlabRoot, startDir);
        if contains(includePath, "$(")
            continue
        end
        includeFlags(end + 1) = "-I""" + includePath + """"; %#ok<AGROW>
    end

    includeFlags = unique(includeFlags, "stable");
end

function includePath = expandMakeTokens(includePath, matlabRoot, startDir)
%EXPANDMAKETOKENS - Replace make_rtw include-path tokens with concrete folders.
%   Local helper for collectIncludeFlags. Substitutes $(MATLAB_ROOT) and
%   $(ALT_MATLAB_ROOT) with matlabRoot. When startDir is non-empty, also
%   replaces $(START_DIR). Unexpanded tokens are left for the caller to skip.
%
%   Syntax:
%       includePath = expandMakeTokens(includePath, matlabRoot, startDir)
%
%   Inputs:
%       includePath - string path that may contain make tokens.
%       matlabRoot - string MATLAB root with forward slashes.
%       startDir - string start directory; empty means do not expand START_DIR.
%
%   Outputs:
%       includePath - string path after token substitution.
%
%   Example:
%       p = expandMakeTokens("$(MATLAB_ROOT)/rtw/c/src", "/opt/matlab", "");
%
%   See also: COLLECTINCLUDEFLAGS
    includePath = replace(includePath, "$(MATLAB_ROOT)", matlabRoot);
    includePath = replace(includePath, "$(ALT_MATLAB_ROOT)", matlabRoot);
    if strlength(startDir) > 0
        includePath = replace(includePath, "$(START_DIR)", startDir);
    end
end
