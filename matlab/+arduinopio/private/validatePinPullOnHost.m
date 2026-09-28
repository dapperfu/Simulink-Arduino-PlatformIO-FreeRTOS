function validatePinPullOnHost(pinPull)
%VALIDATEPINPULLONHOST - Error if Pull-down is requested on an unsupported board.
%   MATLAB-only. Maps pinPull with pinPullIndex; indices 0 and 1 always pass.
%   Index 2 requires HasInputPulldown on getBoard(); otherwise errors
%   arduinopio:InvalidPinPull. Private; called from validatePinPull.
%
%   Syntax:
%       validatePinPullOnHost(pinPull)
%
%   Inputs:
%       pinPull - numeric 0:2 or text None/Pull-up/Pull-down (see pinPullIndex).
%
%   Outputs:
%       none
%
%   Example:
%       validatePinPullOnHost("Pull-up");
%
%   Other m-files required: arduinopio.pinPullIndex, arduinopio.boards.getBoard
%   Subfunctions: none
%   MAT-files required: none
%
%   See also: VALIDATEPINPULL, PINPULLINDEX, GETBOARD

%   Author: Frey, Jed
%   28-Sep-2026; Last revision: 28-Sep-2026

%------------- BEGIN CODE --------------
    index = arduinopio.pinPullIndex(pinPull);
    if index < 2
        return
    end

    info = arduinopio.boards.getBoard();
    hasPulldown = isfield(info, "HasInputPulldown") && info.HasInputPulldown;
    if ~hasPulldown
        error("arduinopio:InvalidPinPull", ...
            "%s does not support INPUT_PULLDOWN. Choose None or Pull-up.", ...
            info.DisplayName);
    end
end
