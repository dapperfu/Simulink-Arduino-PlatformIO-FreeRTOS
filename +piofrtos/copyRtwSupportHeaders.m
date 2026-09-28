function copiedFiles = copyRtwSupportHeaders(buildDir)
%copyRtwSupportHeaders Copy ERT headers referenced by generated model code.
    arguments
        buildDir (1, 1) string
    end

    if ~isfolder(buildDir)
        mkdir(buildDir);
    end

    headerNames = ["rtw_continuous.h"; "rtw_solver.h"];
    sourceFolder = fullfile(matlabroot, "simulink", "include");
    copiedFiles = string.empty(0, 1);

    for headerIndex = 1:numel(headerNames)
        headerName = headerNames(headerIndex);
        sourceFile = fullfile(sourceFolder, headerName);
        destFile = fullfile(buildDir, headerName);
        if ~isfile(sourceFile)
            continue
        end
        copyfile(sourceFile, destFile);
        copiedFiles(end + 1, 1) = destFile; %#ok<AGROW>
    end
end
