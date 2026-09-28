function makeInfo = rtwmakecfg()
%RTWMAKECFG - Add Arduino PIO driver sources for I/O S-function codegen.
%   Returns a makeInfo struct used by Simulink Coder / Embedded Coder when
%   building models that reference S-functions in this folder. includePath and
%   sourcePath point at src/drivers under the toolbox root. sources lists
%   arduinopio_uart.cpp, arduinopio_extint.cpp, and arduinopio_hwint_avr.cpp.
%   linkLibsObjs is empty.
%
%   Syntax:
%       makeInfo = rtwmakecfg()
%
%   Inputs:
%       none
%
%   Outputs:
%       makeInfo - Struct with includePath, sourcePath, sources, linkLibsObjs
%
%   Example:
%       makeInfo = rtwmakecfg();
%
%   Other m-files required: arduinopio.getRootFolder
%   Subfunctions: none
%   MAT-files required: none
%
%   See also: BUILDARDUINOPIOSFUNCTIONS, ARDUINOPIO_SERIAL_RECEIVE

%   Author: Frey, Jed
%   28-Sep-2026; Last revision: 28-Sep-2026

%------------- BEGIN CODE --------------

    rootDir = arduinopio.getRootFolder();
    srcDir = fullfile(rootDir, "src", "drivers");
    makeInfo.includePath = {char(srcDir)};
    makeInfo.sourcePath = {char(srcDir)};
    makeInfo.sources = { ...
        "arduinopio_uart.cpp", ...
        "arduinopio_extint.cpp", ...
        "arduinopio_hwint_avr.cpp"};
    makeInfo.linkLibsObjs = {};
end
