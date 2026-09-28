function includeFlags = collectIncludeFlags(includePaths, options)
%collectIncludeFlags Convert include paths into PlatformIO -I flags.
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
    includePath = replace(includePath, "$(MATLAB_ROOT)", matlabRoot);
    includePath = replace(includePath, "$(ALT_MATLAB_ROOT)", matlabRoot);
    if strlength(startDir) > 0
        includePath = replace(includePath, "$(START_DIR)", startDir);
    end
end
