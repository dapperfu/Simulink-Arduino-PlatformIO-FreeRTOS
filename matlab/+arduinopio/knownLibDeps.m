function deps = knownLibDeps()
%knownLibDeps Return PlatformIO lib_deps keyed by codegen preprocessor defines.

    deps = struct( ...
        "Define", {"ARDUINOPIO_NEED_SERVO", "ARDUINOPIO_NEED_MCP2515"}, ...
        "LibDep", {"Servo", "autowp/autowp-mcp2515"});
end
