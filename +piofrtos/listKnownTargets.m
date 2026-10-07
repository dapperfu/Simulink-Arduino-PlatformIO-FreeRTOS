function targets = listKnownTargets()
%LISTKNOWNTARGETS - Return PlatformIO targets known to work with this STF.
%   Defines the curated board list for the piofrtos Arduino FreeRTOS Simulink
%   target. AVR entries use feilipu/FreeRTOS. ESP32, Due, MKR, Uno R4, and
%   Nano 33 BLE are included so the dialog can fill platform and framework.
%   Non-AVR ExtraLibraries stay empty. Consumed by getOptionTable,
%   resolveKnownTarget, and related UI sync helpers.
%
%   Syntax:
%       targets = piofrtos.listKnownTargets()
%
%   Inputs:
%       none
%
%   Outputs:
%       targets - struct array with fields DisplayName, Platform, Board,
%           Framework, ExtraLibraries, TaskStackWords (all string-valued).
%
%   Example:
%       % List display names shown in the PioBoard popup.
%       targets = piofrtos.listKnownTargets();
%
%   Other m-files required: none
%   Subfunctions: knownTarget
%   MAT-files required: none
%
%   See also: RESOLVEKNOWNTARGET, GETOPTIONTABLE, SYNCKNOWNTARGET

%   Author: Frey, Jed
%   28-Sep-2026; Last revision: 28-Sep-2026

%------------- BEGIN CODE --------------
    targets = [ ...
        knownTarget("Arduino Uno", "atmelavr", "uno", "arduino", "feilipu/FreeRTOS", "192")
        knownTarget("Arduino Nano", "atmelavr", "nanoatmega328", "arduino", "feilipu/FreeRTOS", "192")
        knownTarget("Arduino Mega 2560", "atmelavr", "megaatmega2560", "arduino", "feilipu/FreeRTOS", "256")
        knownTarget("Arduino Due", "atmelsam", "due", "arduino", "", "512")
        knownTarget("Arduino MKR WiFi 1010", "atmelsam", "mkrwifi1010", "arduino", "", "512")
        knownTarget("ESP32-WROOM", "espressif32", "esp32dev", "arduino", "", "4096")
        knownTarget("Arduino Uno R4 WiFi", "renesas-ra", "uno_r4_wifi", "arduino", "", "1024")
        knownTarget("Arduino Nano 33 BLE", "nordicnrf52", "nano33ble", "arduino", "", "1024")];
end

function target = knownTarget(displayName, platform, board, framework, extraLibraries, taskStackWords)
%KNOWNTARGET - Build one known PlatformIO board struct for piofrtos.
%   Local constructor used by listKnownTargets. extraLibraries may be empty
%   when the core already provides the scheduler. taskStackWords is the
%   xTaskCreate stack depth stored on the target.
%
%   Syntax:
%       target = knownTarget(displayName, platform, board, framework)
%
%   Inputs:
%       displayName - char/string UI label (e.g. "Arduino Uno").
%       platform - PlatformIO platform id (e.g. "atmelavr").
%       board - PlatformIO board id (e.g. "uno").
%       framework - PlatformIO framework id (e.g. "arduino").
%
%   Outputs:
%       target - scalar struct with DisplayName, Platform, Board, Framework,
%           ExtraLibraries, and TaskStackWords fields as strings.
%
%   Example:
%       t = knownTarget("Arduino Uno", "atmelavr", "uno", "arduino", ...
%           "feilipu/FreeRTOS", "192");
%
%   See also: LISTKNOWNTARGETS
    target = struct( ...
        "DisplayName", string(displayName), ...
        "Platform", string(platform), ...
        "Board", string(board), ...
        "Framework", string(framework), ...
        "ExtraLibraries", string(extraLibraries), ...
        "TaskStackWords", string(taskStackWords));
end
