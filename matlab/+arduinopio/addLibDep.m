function addLibDep(buildInfo, depName)
%addLibDep Record a PlatformIO library dependency on the codegen build info.
%   Adds ARDUINOPIO_NEED_<DEP> so the target can emit platformio.ini lib_deps.

    arguments
        buildInfo
        depName (1,1) string
    end

    defineName = "ARDUINOPIO_NEED_" + upper(depName);
    addDefines(buildInfo, defineName);
    tokenName = "|>" + defineName + "<|";
    addTMFTokens(buildInfo, tokenName, "1");
end
