function blockPaths = listLibraryBlocks()
%LISTLIBRARYBLOCKS - Return leaf block paths in libraries/arduinopio_lib.slx.
%   Loads the library if needed, walks top-level subsystem folders, and collects
%   leaf blocks. Unmasked nested subsystems contribute their children instead of
%   themselves. Errors arduinopio:LibraryMissing if the .slx is absent. Package
%   path: arduinopio.listLibraryBlocks.
%
%   Syntax:
%       blockPaths = arduinopio.listLibraryBlocks()
%
%   Inputs:
%       none
%
%   Outputs:
%       blockPaths - string column. Full paths such as arduinopio_lib/.../Block.
%
%   Example:
%       paths = arduinopio.listLibraryBlocks();
%
%   Other m-files required: arduinopio.getRootFolder
%   Subfunctions: isUnmaskedSubsystem
%   MAT-files required: none
%
%   See also: GETROOTFOLDER, GENERATELIBRARYBLOCKCODE, LISTEXAMPLEMODELS

%   Author: Frey, Jed
%   28-Sep-2026; Last revision: 28-Sep-2026

%------------- BEGIN CODE --------------
    libName = "arduinopio_lib";
    libPath = fullfile(arduinopio.getRootFolder(), "libraries", libName + ".slx");
    if ~isfile(libPath)
        error("arduinopio:LibraryMissing", ...
            "Library not found. Run createArduinoPioLibrary.");
    end

    if ~bdIsLoaded(libName)
        load_system(libPath);
    end

    topFolders = string(find_system(libName, SearchDepth=1, BlockType="SubSystem"));
    blockPaths = strings(0, 1);
    for folderIndex = 1:numel(topFolders)
        folderPath = topFolders(folderIndex);
        if folderPath == libName
            continue
        end
        children = string(find_system(folderPath, SearchDepth=1, Type="Block"));
        for childIndex = 1:numel(children)
            childPath = children(childIndex);
            if childPath == folderPath
                continue
            end
            if isUnmaskedSubsystem(childPath)
                grandchildren = string(find_system(childPath, SearchDepth=1, Type="Block"));
                for grandIndex = 1:numel(grandchildren)
                    grandPath = grandchildren(grandIndex);
                    if grandPath ~= childPath
                        blockPaths(end+1, 1) = grandPath; %#ok<AGROW>
                    end
                end
            else
                blockPaths(end+1, 1) = childPath; %#ok<AGROW>
            end
        end
    end
end

function tf = isUnmaskedSubsystem(blockPath)
%ISUNMASKEDSUBSYSTEM - True when blockPath is a SubSystem with Mask off.
%   Used to expand grouping subsystems into their child leaf blocks.
%
%   Syntax:
%       tf = isUnmaskedSubsystem(blockPath)
%
%   Inputs:
%       blockPath - string. Simulink block path inside the library.
%
%   Outputs:
%       tf - logical. True for unmasked SubSystem blocks.
%
%   Example:
%       tf = isUnmaskedSubsystem("arduinopio_lib/Digital");
%
%   See also: LISTLIBRARYBLOCKS
    tf = string(get_param(blockPath, "BlockType")) == "SubSystem" && ...
        string(get_param(blockPath, "Mask")) == "off";
end
