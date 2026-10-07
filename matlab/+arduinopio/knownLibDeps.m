function deps = knownLibDeps()
%KNOWNLIBDEPS - Return PlatformIO lib_deps keyed by codegen preprocessor defines.
%   Struct array maps Define names to LibDep strings used when emitting
%   platformio.ini dependencies. Package path: arduinopio.knownLibDeps.
%
%   Syntax:
%       deps = arduinopio.knownLibDeps()
%
%   Inputs:
%       none
%
%   Outputs:
%       deps - struct array with fields:
%           Define - ARDUINOPIO_NEED_SERVO, MCP2515, WIFININA, WIFIS3,
%               ARDUINOBLE, ARDUINO_CAN, LED_MATRIX;
%           LibDep - Servo, autowp/autowp-mcp2515, WiFiNINA, WiFiS3,
%               ArduinoBLE, Arduino_CAN, Arduino_LED_Matrix.
%
%   Example:
%       deps = arduinopio.knownLibDeps();
%
%   Other m-files required: none
%   Subfunctions: none
%   MAT-files required: none
%
%   See also: ADDLIBDEP, UPDATEDRIVERBUILDINFO

%   Author: Frey, Jed
%   28-Sep-2026; Last revision: 28-Sep-2026

%------------- BEGIN CODE --------------
    deps = struct( ...
        "Define", {"ARDUINOPIO_NEED_SERVO", "ARDUINOPIO_NEED_MCP2515", ...
        "ARDUINOPIO_NEED_WIFININA", "ARDUINOPIO_NEED_WIFIS3", ...
        "ARDUINOPIO_NEED_ARDUINOBLE", "ARDUINOPIO_NEED_ARDUINO_CAN", ...
        "ARDUINOPIO_NEED_LED_MATRIX"}, ...
        "LibDep", {"Servo", "autowp/autowp-mcp2515", ...
        "WiFiNINA", "arduino-libraries/WiFiS3", ...
        "ArduinoBLE", "arduino-libraries/Arduino_CAN", ...
        "arduino-libraries/Arduino_LED_Matrix"});
end
