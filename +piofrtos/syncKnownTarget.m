function syncKnownTarget(hDlg, hSrc)
%SYNCKNOWNTARGET - Fill platform and framework from the selected known board.
%   Configuration UI callback for the PioBoard rtwoption (wired from
%   getOptionTable). Reads PioBoard via getConfigValue, resolves it with
%   resolveKnownTarget, and when isKnown is true writes PioPlatform,
%   PioFramework, PioExtraLibraries, and PioTaskStackWords from the known
%   target. Unknown boards leave other fields
%   unchanged. Supports both slConfigUI* dialog APIs and hSrc get/set_param.
%
%   Syntax:
%       piofrtos.syncKnownTarget(hDlg, hSrc)
%
%   Inputs:
%       hDlg - Configuration Parameters dialog handle (may be unused when
%           falling back to hSrc.get_param / set_param).
%       hSrc - Config set or UI source object exposing the Pio* parameters.
%
%   Outputs:
%       none
%
%   Example:
%       % Invoked automatically when the PioBoard popup changes in the STF UI.
%       piofrtos.syncKnownTarget(hDlg, hSrc);
%
%   Other m-files required: resolveKnownTarget
%   Subfunctions: getConfigValue, setConfigValue
%   MAT-files required: none
%
%   See also: RESOLVEKNOWNTARGET, GETOPTIONTABLE, SELECTCALLBACK

%   Author: Frey, Jed
%   28-Sep-2026; Last revision: 28-Sep-2026

%------------- BEGIN CODE --------------
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
    setConfigValue(hDlg, hSrc, "PioExtraLibraries", target.ExtraLibraries);
    setConfigValue(hDlg, hSrc, "PioTaskStackWords", target.TaskStackWords);
end

function value = getConfigValue(hDlg, hSrc, parameterName)
%GETCONFIGVALUE - Read a config parameter from dialog UI or source object.
%   Local helper for syncKnownTarget. Tries slConfigUIGetVal first, then
%   hSrc.get_param. Returns "" when both fail (rtwoptions not yet attached).
%
%   Syntax:
%       value = getConfigValue(hDlg, hSrc, parameterName)
%
%   Inputs:
%       hDlg - Configuration Parameters dialog handle.
%       hSrc - Config set / UI source object.
%       parameterName - char/string parameter name such as "PioBoard".
%
%   Outputs:
%       value - string parameter value, or "" if unavailable.
%
%   Example:
%       boardId = getConfigValue(hDlg, hSrc, "PioBoard");
%
%   See also: SYNCKNOWNTARGET, SETCONFIGVALUE
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
%SETCONFIGVALUE - Write a config parameter via dialog UI or source object.
%   Local helper for syncKnownTarget. Tries slConfigUISetVal, then
%   hSrc.set_param. Silent when the parameter is absent until ERT attaches.
%
%   Syntax:
%       setConfigValue(hDlg, hSrc, parameterName, parameterValue)
%
%   Inputs:
%       hDlg - Configuration Parameters dialog handle.
%       hSrc - Config set / UI source object.
%       parameterName - char/string parameter name such as "PioPlatform".
%       parameterValue - value to assign (typically a string from the known target).
%
%   Outputs:
%       none
%
%   Example:
%       setConfigValue(hDlg, hSrc, "PioPlatform", target.Platform);
%
%   See also: SYNCKNOWNTARGET, GETCONFIGVALUE
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
