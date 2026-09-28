function [target, isKnown] = resolveKnownTarget(boardId)
%resolveKnownTarget Map a board display name or PlatformIO id to a known target.
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
    aliases = lower([target.DisplayName, target.Board]);
    tf = ismember(lower(boardId), aliases);
end
