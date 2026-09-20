function deps = knownLibDeps()
%knownLibDeps Return PlatformIO lib_deps keyed by codegen preprocessor defines.

    deps = struct( ...
        "Define", {"ARDUINOPIO_NEED_SERVO"}, ...
        "LibDep", {"Servo"});
end
