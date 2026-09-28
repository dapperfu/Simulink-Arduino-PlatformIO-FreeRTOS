function writtenFiles = writeGeneratedFiles(modelName, buildInfo)
%writeGeneratedFiles Emit platformio.ini, FreeRTOS main, and pio_cmd.mk.
    arguments
        modelName (1,1) string
        buildInfo = []
    end

    buildDir = piofrtos.getBuildDirectory(modelName);
    if ~isfolder(buildDir)
        mkdir(buildDir);
    end

    modelOptions = piofrtos.getModelOptions(modelName);
    rates = piofrtos.getModelSampleRates(modelName, buildDir);
    [headerFile, initFunction] = getGeneratedEntryPoints(modelName, buildDir);

    iniPath = fullfile(buildDir, "platformio.ini");
    mainPath = fullfile(buildDir, "main.cpp");
    mkPath = fullfile(buildDir, "pio_cmd.mk");

    copyExtraSources(buildDir, buildInfo);
    piofrtos.copyRtwSupportHeaders(buildDir);
    includeFlags = piofrtos.collectIncludeFlags(includePathsFromBuildInfo(buildInfo), ...
        StartDir=replace(string(fileparts(buildDir)), "\", "/"));
    extraLibraries = mergeLibraries(modelOptions.PioExtraLibraries, buildInfo);
    numstDefine = "-DNUMST=" + string(numel(rates));

    piofrtos.emitPlatformioIni(iniPath, ...
        ModelName=modelName, ...
        Platform=modelOptions.PioPlatform, ...
        Board=modelOptions.PioBoard, ...
        Framework=modelOptions.PioFramework, ...
        ExtraLibraries=extraLibraries, ...
        MonitorSpeed=modelOptions.PioMonitorSpeed, ...
        IncludeFlags=includeFlags, ...
        Defines=numstDefine);

    piofrtos.emitFreeRtosMain(mainPath, modelName, rates, ...
        HeaderFile=headerFile, ...
        InitFunction=initFunction, ...
        StackWords=modelOptions.PioTaskStackWords, ...
        MonitorSpeed=modelOptions.PioMonitorSpeed);

    writePioCommandMakefile(mkPath);

    writtenFiles = [iniPath; mainPath; mkPath];
end

function [headerFile, initFunction] = getGeneratedEntryPoints(modelName, buildDir)
    headerFile = modelName + ".h";
    initFunction = modelName + "_initialize";

    try
        codeDescriptor = coder.getCodeDescriptor(char(buildDir));
        initInterfaces = codeDescriptor.getFunctionInterfaces("Initialize");
        if isempty(initInterfaces)
            return
        end
        initFunction = string(initInterfaces(1).Prototype.Name);
        protoHeader = string(initInterfaces(1).Prototype.HeaderFile);
        if strlength(protoHeader) > 0
            headerFile = protoHeader;
        end
    catch
        % Code descriptor is unavailable until after a successful TLC pass.
    end
end

function includePaths = includePathsFromBuildInfo(buildInfo)
    includePaths = string.empty(0, 1);
    if isempty(buildInfo)
        return
    end

    try
        includePaths = string(buildInfo.getIncludePaths(true));
    catch
        try
            includePaths = string(buildInfo.getIncludePaths(false));
        catch
            try
                includePaths = string(buildInfo.getIncludePaths());
            catch
                % Build info may not expose include paths at this hook stage.
                return
            end
        end
    end

    includePaths = includePaths(:);
end

function extraLibraries = mergeLibraries(optionLibraries, buildInfo)
    pieces = [piofrtos.normalizeLibraries(optionLibraries); librariesFromBuildInfo(buildInfo)];
    if isempty(pieces)
        extraLibraries = "";
    else
        extraLibraries = strjoin(pieces, ", ");
    end
end

function libraries = librariesFromBuildInfo(buildInfo)
    libraries = string.empty(0, 1);
    if isempty(buildInfo) || exist("arduinopio.knownLibDeps", "file") == 0
        return
    end

    try
        defines = string(buildInfo.getDefines());
        knownDeps = arduinopio.knownLibDeps();
    catch
        % Blockset library metadata is optional for the core target.
        return
    end

    defineText = join(defines, " ");
    for depIndex = 1:numel(knownDeps)
        if contains(defineText, knownDeps(depIndex).Define)
            libraries(end+1, 1) = knownDeps(depIndex).LibDep; %#ok<AGROW>
        end
    end
end

function copyExtraSources(buildDir, buildInfo)
    if isempty(buildInfo)
        return
    end

    try
        sourceFiles = string(buildInfo.getSourceFiles(true, true));
    catch
        try
            sourceFiles = string(buildInfo.getSourceFiles());
        catch
            return
        end
    end

    buildDirNormalized = replace(buildDir, "\", "/");
    for fileIndex = 1:numel(sourceFiles)
        sourceFile = string(sourceFiles(fileIndex));
        if ~isfile(sourceFile)
            continue
        end
        sourceFolder = replace(string(fileparts(sourceFile)), "\", "/");
        if startsWith(sourceFolder, buildDirNormalized)
            continue
        end

        [~, baseName, ext] = fileparts(sourceFile);
        destFile = fullfile(buildDir, baseName + ext);
        copyfile(sourceFile, destFile);
        headerFile = fullfile(fileparts(sourceFile), baseName + ".h");
        if isfile(headerFile)
            copyfile(headerFile, fullfile(buildDir, baseName + ".h"));
        end
    end
end

function writePioCommandMakefile(mkPath)
    pioCmd = piofrtos.locatePlatformio(MustExist=false);
    if strlength(pioCmd) == 0
        pioCmd = "pio";
    end
    lines = [
        "# Generated by piofrtos.writeGeneratedFiles"
        "PIO_CMD = " + pioCmd
        ];
    writelines(lines, mkPath);
end
