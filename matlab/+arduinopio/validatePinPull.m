function validatePinPull(pinPull)
%validatePinPull Error if PINPULL is not valid for the active board.
%   Board maps are MATLAB-only; code generation skips the host lookup.

    coder.extrinsic("validatePinPullOnHost");
    if coder.target("MATLAB")
        validatePinPullOnHost(pinPull);
    end
end
