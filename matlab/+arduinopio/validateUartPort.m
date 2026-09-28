function validateUartPort(port)
%validateUartPort Error if PORT is not a valid UART index on the active board.
%   Board maps are MATLAB-only; code generation skips the host lookup.

    arguments
        port (1,1) {mustBeNumeric, mustBeInteger, mustBeNonnegative}
    end

    coder.extrinsic("validateUartPortOnHost");
    if coder.target("MATLAB")
        validateUartPortOnHost(port);
    end
end
