function warnIfNotLibraryOnHost(warningId, messageText)
%warnIfNotLibraryOnHost MATLAB-only library-diagram warning.

    try
        if string(get_param(bdroot, "BlockDiagramType")) == "library"
            return
        end
    catch
        % No diagram is loaded. Continue and warn.
    end
    warning(warningId, "%s", messageText);
end
