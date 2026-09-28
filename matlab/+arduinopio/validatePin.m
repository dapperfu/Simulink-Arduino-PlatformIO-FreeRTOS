function validatePin(pin, kind)
%validatePin Error if PIN is not valid for KIND on the active board.
%   KIND is "digital", "analog", "pwm", "interrupt", or "capture".
%   Board maps are MATLAB-only; code generation skips the host lookup.

    arguments
        pin (1,1) {mustBeNumeric, mustBeInteger}
        kind {mustBeTextScalar, mustBeMember(kind, {'digital', 'analog', 'pwm', 'interrupt', 'capture'})}
    end

    coder.extrinsic("validatePinOnHost");
    if coder.target("MATLAB")
        validatePinOnHost(pin, kind);
    end
end
