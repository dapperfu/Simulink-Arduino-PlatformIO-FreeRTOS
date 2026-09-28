function libraries = normalizeLibraries(extraLibraries)
%normalizeLibraries Split a free-form lib_deps string into library entries.
    arguments
        extraLibraries (1,1) string
    end

    if strlength(strip(extraLibraries)) == 0
        libraries = string.empty(0, 1);
        return
    end

    pieces = split(extraLibraries, [",", ";", newline, sprintf("\r")]);
    pieces = strip(pieces);
    libraries = pieces(strlength(pieces) > 0);
    if isempty(libraries)
        libraries = string.empty(0, 1);
    end
end
