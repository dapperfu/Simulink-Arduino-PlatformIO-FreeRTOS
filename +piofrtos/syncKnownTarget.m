function syncKnownTarget(hDlg, hSrc)
%syncKnownTarget Fill platform and framework from the selected known board.
    arguments
        hDlg
        hSrc
    end

    boardId = getConfigValue(hDlg, hSrc, "PioBoard");
    [target, isKnown] = piofrtos.resolveKnownTarget(boardId);
    if ~isKnown
        return
    end

    setConfigValue(hDlg, hSrc, "PioPlatform", target.Platform);
    setConfigValue(hDlg, hSrc, "PioFramework", target.Framework);
end

function value = getConfigValue(hDlg, hSrc, parameterName)
    value = "";
    try
        value = string(slConfigUIGetVal(hDlg, hSrc, parameterName));
    catch
        try
            value = string(hSrc.get_param(parameterName));
        catch
            % Custom rtwoptions are unavailable until this target is selected.
        end
    end
end

function setConfigValue(hDlg, hSrc, parameterName, parameterValue)
    try
        slConfigUISetVal(hDlg, hSrc, parameterName, parameterValue);
    catch
        try
            hSrc.set_param(parameterName, parameterValue);
        catch
            % Parameter may be absent until the ERT config component is attached.
        end
    end
end
