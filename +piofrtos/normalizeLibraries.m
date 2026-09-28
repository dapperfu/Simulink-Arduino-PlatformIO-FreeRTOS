function libraries = normalizeLibraries(extraLibraries)
%NORMALIZELIBRARIES - Split a free-form lib_deps string into library entries.
%   Parses PioExtraLibraries / ExtraLibraries text for the piofrtos PlatformIO
%   target. Splits on commas, semicolons, newline, and carriage return, strips
%   whitespace, and drops empty pieces. Returns an empty (0x1) string array
%   when the input is blank or only separators. Used by emitPlatformioIni and
%   writeGeneratedFiles (via mergeLibraries).
%
%   Syntax:
%       libraries = piofrtos.normalizeLibraries(extraLibraries)
%
%   Inputs:
%       extraLibraries - (1,1) string of PlatformIO lib_deps entries separated
%           by commas or semicolons (or newlines). Empty/whitespace yields [].
%
%   Outputs:
%       libraries - column string array of non-empty library dependency strings.
%
%   Example:
%       % Split AVR FreeRTOS and another lib_deps entry.
%       libs = piofrtos.normalizeLibraries("feilipu/FreeRTOS, some/Lib");
%
%   Other m-files required: none
%   Subfunctions: none
%   MAT-files required: none
%
%   See also: EMITPLATFORMIOINI, WRITEGENERATEDFILES, GETOPTIONTABLE

%   Author: Frey, Jed
%   28-Sep-2026; Last revision: 28-Sep-2026

%------------- BEGIN CODE --------------
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
