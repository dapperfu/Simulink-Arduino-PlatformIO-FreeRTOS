function warnIfNotLibrary(warningId, messageText)
%warnIfNotLibrary Issue a warning unless the current diagram is a library.
%   Diagram queries are MATLAB-only; code generation skips the warning.

    arguments
        warningId (1,1) string
        messageText (1,1) string
    end

    coder.extrinsic("warnIfNotLibraryOnHost");
    if coder.target("MATLAB")
        warnIfNotLibraryOnHost(warningId, messageText);
    end
end
