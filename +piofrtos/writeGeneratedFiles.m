function writtenFiles = writeGeneratedFiles(modelName, buildInfo)
%WRITEGENERATEDFILES - Emit platformio.ini, FreeRTOS main, and pio_cmd.mk.
%   Primary code-generation hook for the piofrtos Arduino FreeRTOS PlatformIO
%   Simulink target. Ensures the model build directory exists, reads model
%   options and discrete sample rates, copies extra buildInfo sources and
%   RTW support headers, then writes platformio.ini via emitPlatformioIni,
%   main.cpp via emitFreeRtosMain, and pio_cmd.mk with locatePlatformio.
%   Defines -DNUMST from the rate count. buildInfo may be empty before TLC.
%
%   Syntax:
%       writtenFiles = piofrtos.writeGeneratedFiles(modelName)
%       writtenFiles = piofrtos.writeGeneratedFiles(modelName, buildInfo)
%
%   Inputs:
%       modelName - (1,1) string Simulink model name.
%       buildInfo - RTW.BuildInfo or compatible object. Default: []. When empty,
%           include paths, extra sources, and knownLibDeps lookups are skipped.
%
%   Outputs:
%       writtenFiles - 3x1 string column [platformio.ini; main.cpp; pio_cmd.mk]
%           paths under the model build directory.
%
%   Example:
%       % Write PlatformIO project files into the model RTW folder.
%       writtenFiles = piofrtos.writeGeneratedFiles("blink");
%
%   Other m-files required: getBuildDirectory, getModelOptions, getModelSampleRates, ...
%       copyRtwSupportHeaders, collectIncludeFlags, emitPlatformioIni, ...
%       emitFreeRtosMain, normalizeLibraries, locatePlatformio
%   Subfunctions: getGeneratedEntryPoints, includePathsFromBuildInfo, ...
%       mergeLibraries, librariesFromBuildInfo, copyExtraSources, writePioCommandMakefile
%   MAT-files required: none
%
%   See also: EMITPLATFORMIOINI, EMITFREERTOSMAIN, GETMODELSAMPLERATES

%   Author: Frey, Jed
%   28-Sep-2026; Last revision: 28-Sep-2026

%------------- BEGIN CODE --------------
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
%GETGENERATEDENTRYPOINTS - Resolve model header and initialize function names.
%   Local helper for writeGeneratedFiles. Defaults to modelName.h and
%   modelName_initialize. When coder.getCodeDescriptor succeeds, uses the
%   first Initialize function Prototype.Name and optional HeaderFile.
%
%   Syntax:
%       [headerFile, initFunction] = getGeneratedEntryPoints(modelName, buildDir)
%
%   Inputs:
%       modelName - string model name for defaults.
%       buildDir - string code generation folder for the code descriptor.
%
%   Outputs:
%       headerFile - string header file name to #include from main.cpp.
%       initFunction - string C initialize function name called from setup().
%
%   Example:
%       [h, init] = getGeneratedEntryPoints("blink", buildDir);
%
%   See also: WRITEGENERATEDFILES, EMITFREERTOSMAIN
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
%INCLUDEPATHSFROMBUILDINFO - Extract include directories from RTW build info.
%   Local helper for writeGeneratedFiles. Tries getIncludePaths(true), then
%   (false), then (). Returns empty (0x1) string when buildInfo is empty or
%   all calls fail at this hook stage.
%
%   Syntax:
%       includePaths = includePathsFromBuildInfo(buildInfo)
%
%   Inputs:
%       buildInfo - RTW.BuildInfo-like object, or [] to skip.
%
%   Outputs:
%       includePaths - column string array of include directories.
%
%   Example:
%       includePaths = includePathsFromBuildInfo(buildInfo);
%
%   See also: WRITEGENERATEDFILES, COLLECTINCLUDEFLAGS
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
%MERGELIBRARIES - Combine model option libs with buildInfo-derived lib_deps.
%   Local helper for writeGeneratedFiles. Concatenates normalizeLibraries
%   results with librariesFromBuildInfo, then joins with ", " or returns ""
%   when empty.
%
%   Syntax:
%       extraLibraries = mergeLibraries(optionLibraries, buildInfo)
%
%   Inputs:
%       optionLibraries - string PioExtraLibraries from model options.
%       buildInfo - RTW build info or [] for optional knownLibDeps lookup.
%
%   Outputs:
%       extraLibraries - (1,1) string of comma-separated lib_deps, or "".
%
%   Example:
%       extraLibraries = mergeLibraries(modelOptions.PioExtraLibraries, buildInfo);
%
%   See also: NORMALIZELIBRARIES, LIBRARIESFROMBUILDINFO
    pieces = [piofrtos.normalizeLibraries(optionLibraries); librariesFromBuildInfo(buildInfo)];
    if isempty(pieces)
        extraLibraries = "";
    else
        extraLibraries = strjoin(pieces, ", ");
    end
end

function libraries = librariesFromBuildInfo(buildInfo)
%LIBRARIESFROMBUILDINFO - Map build defines to known Arduino blockset lib_deps.
%   Local helper for mergeLibraries. Requires arduinopio.knownLibDeps on the
%   path. For each known dependency whose Define appears in buildInfo
%   getDefines(), appends LibDep. Returns empty when buildInfo is empty,
%   knownLibDeps is missing, or lookups fail.
%
%   Syntax:
%       libraries = librariesFromBuildInfo(buildInfo)
%
%   Inputs:
%       buildInfo - RTW build info exposing getDefines(), or [].
%
%   Outputs:
%       libraries - column string array of PlatformIO lib_deps entries.
%
%   Example:
%       libraries = librariesFromBuildInfo(buildInfo);
%
%   See also: MERGELIBRARIES, WRITEGENERATEDFILES
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
%COPYEXTRASOURCES - Copy non-local buildInfo sources (and .h twins) into buildDir.
%   Local helper for writeGeneratedFiles. Uses getSourceFiles(true, true) or
%   getSourceFiles(). Skips missing files and sources already under buildDir.
%   Also copies basename.h from the same folder when present.
%
%   Syntax:
%       copyExtraSources(buildDir, buildInfo)
%
%   Inputs:
%       buildDir - string destination build / PlatformIO project folder.
%       buildInfo - RTW build info or [] (no-op).
%
%   Outputs:
%       none
%
%   Example:
%       copyExtraSources(buildDir, buildInfo);
%
%   See also: WRITEGENERATEDFILES
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
%WRITEPIOCOMMANDMAKEFILE - Write pio_cmd.mk defining PIO_CMD for the TMF.
%   Local helper for writeGeneratedFiles. Uses locatePlatformio(MustExist=false)
%   and falls back to "pio" when empty. Writes two lines consumed by
%   piofrtos.tmf via -include pio_cmd.mk.
%
%   Syntax:
%       writePioCommandMakefile(mkPath)
%
%   Inputs:
%       mkPath - string path to pio_cmd.mk under the build directory.
%
%   Outputs:
%       none
%
%   Example:
%       writePioCommandMakefile(fullfile(buildDir, "pio_cmd.mk"));
%
%   See also: LOCATEPLATFORMIO, WRITEGENERATEDFILES
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
