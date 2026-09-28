function blockPaths = listLibraryBlocks()
%listLibraryBlocks Return leaf block paths in libraries/arduinopio_lib.slx.

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
    tf = string(get_param(blockPath, "BlockType")) == "SubSystem" && ...
        string(get_param(blockPath, "Mask")) == "off";
end
