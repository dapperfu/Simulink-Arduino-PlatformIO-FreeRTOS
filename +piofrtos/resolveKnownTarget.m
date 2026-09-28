function [target, isKnown] = resolveKnownTarget(boardId)
%RESOLVEKNOWNTARGET - Map a board display name or PlatformIO id to a known target.
%   Looks up boardId against listKnownTargets DisplayName and Board fields
%   (case-insensitive via matchesKnownTarget). Used by emitPlatformioIni and
%   syncKnownTarget in the piofrtos package to fill Platform and Framework.
%   When no match is found, returns a placeholder struct with Board set to
%   boardId and empty Platform/Framework/ExtraLibraries/TaskStackWords, and
%   isKnown false.
%
%   Syntax:
%       [target, isKnown] = piofrtos.resolveKnownTarget(boardId)
%
%   Inputs:
%       boardId - (1,1) string board display name or PlatformIO board id.
%           Leading/trailing whitespace is stripped before matching.
%
%   Outputs:
%       target - scalar struct with DisplayName, Platform, Board, Framework,
%           ExtraLibraries, TaskStackWords. From the known list when matched;
%           otherwise a stub with DisplayName and Board equal to boardId.
%       isKnown - logical true when boardId matched a curated target.
%
%   Example:
%       % Resolve the Uno entry by display name or board id.
%       [target, isKnown] = piofrtos.resolveKnownTarget("uno");
%
%   Other m-files required: listKnownTargets
%   Subfunctions: matchesKnownTarget
%   MAT-files required: none
%
%   See also: LISTKNOWNTARGETS, SYNCKNOWNTARGET, EMITPLATFORMIOINI

%   Author: Frey, Jed
%   28-Sep-2026; Last revision: 28-Sep-2026

%------------- BEGIN CODE --------------
    arguments
        boardId (1,1) string
    end

    boardId = strip(boardId);
    targets = piofrtos.listKnownTargets();
    for targetIndex = 1:numel(targets)
        candidate = targets(targetIndex);
        if matchesKnownTarget(candidate, boardId)
            target = candidate;
            isKnown = true;
            return
        end
    end

    target = struct( ...
        "DisplayName", boardId, ...
        "Platform", "", ...
        "Board", boardId, ...
        "Framework", "", ...
        "ExtraLibraries", "", ...
        "TaskStackWords", "");
    isKnown = false;
end

function tf = matchesKnownTarget(target, boardId)
%MATCHESKNOWNTARGET - True when boardId matches a target DisplayName or Board.
%   Local helper for resolveKnownTarget. Compares lower(boardId) to the
%   lowercased DisplayName and Board aliases of the candidate struct.
%
%   Syntax:
%       tf = matchesKnownTarget(target, boardId)
%
%   Inputs:
%       target - scalar known-target struct with DisplayName and Board fields.
%       boardId - string id or display name to test (already stripped by caller).
%
%   Outputs:
%       tf - logical true if boardId is a member of the alias list.
%
%   Example:
%       tf = matchesKnownTarget(targets(1), "Arduino Uno");
%
%   See also: RESOLVEKNOWNTARGET
    aliases = lower([target.DisplayName, target.Board]);
    tf = ismember(lower(boardId), aliases);
end
