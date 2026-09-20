function warnIfNotLibrary(warningId, messageText, varargin)
%warnIfNotLibrary Issue a warning unless the current diagram is a library.

    arguments
        warningId (1,1) string
        messageText (1,1) string
    end
    arguments (Repeating)
        varargin
    end

    try
        if string(get_param(bdroot, "BlockDiagramType")) == "library"
            return
        end
    catch
        % No diagram is loaded. Continue and warn.
    end
    warning(warningId, messageText, varargin{:});
end
