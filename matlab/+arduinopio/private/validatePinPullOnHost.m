function validatePinPullOnHost(pinPull)
%validatePinPullOnHost MATLAB-only pull resistor check against the active board.

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
