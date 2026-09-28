function copiedFiles = copyRtwSupportHeaders(buildDir)
%COPYRTWSUPPORTHEADERS - Copy ERT headers referenced by generated model code.
%   Copies rtw_continuous.h and rtw_solver.h from matlabroot/simulink/include
%   into the model build directory used by the piofrtos PlatformIO FreeRTOS
%   target. Creates buildDir when missing. Headers that are absent from the
%   MATLAB install are skipped without error. Called from writeGeneratedFiles
%   so PlatformIO compiles can find the ERT support includes locally.
%
%   Syntax:
%       copiedFiles = piofrtos.copyRtwSupportHeaders(buildDir)
%
%   Inputs:
%       buildDir - (1,1) string path to the code-generation / PlatformIO project
%           folder. Created with mkdir if it does not exist.
%
%   Outputs:
%       copiedFiles - column string array of destination paths that were copied.
%           Empty (0x1) when no source headers were found.
%
%   Example:
%       % Copy ERT support headers next to generated sources.
%       copied = piofrtos.copyRtwSupportHeaders(piofrtos.getBuildDirectory("mymodel"));
%
%   Other m-files required: none
%   Subfunctions: none
%   MAT-files required: none
%
%   See also: WRITEGENERATEDFILES, GETBUILDDIRECTORY

%   Author: Frey, Jed
%   28-Sep-2026; Last revision: 28-Sep-2026

%------------- BEGIN CODE --------------
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
