function updateDriverBuildInfo(buildInfo, context, sourceFiles, libDeps)
%updateDriverBuildInfo Add driver sources, includes, and library defines to codegen.
%   SOURCEFILES and LIBDEPS are string arrays. LIBDEPS may be empty.

    arguments
        buildInfo
        context
        sourceFiles (1,:) string
        libDeps (1,:) string = string.empty(1, 0)
    end

    if ~context.isCodeGenTarget("rtw")
        return
    end

    rootDir = arduinopio.getRootFolder();
    srcDir = fullfile(rootDir, "src", "drivers");
    addIncludePaths(buildInfo, srcDir);
    addSourceFiles(buildInfo, "arduinopio_lock.cpp", srcDir);

    for i = 1:numel(sourceFiles)
        addSourceFiles(buildInfo, sourceFiles(i), srcDir);
    end

    for i = 1:numel(libDeps)
        arduinopio.addLibDep(buildInfo, libDeps(i));
    end
end
