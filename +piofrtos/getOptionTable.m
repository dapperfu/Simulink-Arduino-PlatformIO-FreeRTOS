function optionTable = getOptionTable()
%GETOPTIONTABLE - Return the PlatformIO rtwoptions used to generate TLC and TMF.
%   Builds the struct array of custom Code Generation options for the piofrtos
%   Arduino FreeRTOS (PlatformIO) system target file. Popup choices and
%   defaults are derived from listKnownTargets (first entry is the default
%   board). PioBoard uses callback piofrtos.syncKnownTarget(hDlg, hSrc).
%   generateTargetFiles consumes this table so TLC rtwoptions and TMF make
%   variables stay aligned (PIO_PLATFORM, PIO_BOARD, etc.).
%
%   Syntax:
%       optionTable = piofrtos.getOptionTable()
%
%   Inputs:
%       none
%
%   Outputs:
%       optionTable - 1x7 struct array with fields Name, Prompt, Type, Default,
%           PopupStrings, Callback, TlcVariable, MakeVariable, Tooltip for
%           PioPlatform, PioBoard, PioFramework, PioExtraLibraries,
%           PioMonitorSpeed, PioUpload, and PioTaskStackWords.
%
%   Example:
%       % Inspect make-variable names emitted into piofrtos.tmf.
%       optionTable = piofrtos.getOptionTable();
%
%   Other m-files required: listKnownTargets
%   Subfunctions: joinPopup
%   MAT-files required: none
%
%   See also: GENERATETARGETFILES, LISTKNOWNTARGETS, SYNCKNOWNTARGET

%   Author: Frey, Jed
%   28-Sep-2026; Last revision: 28-Sep-2026

%------------- BEGIN CODE --------------
    targets = piofrtos.listKnownTargets();
    defaultTarget = targets(1);
    platforms = unique([targets.Platform], "stable");
    boards = unique([targets.DisplayName], "stable");
    frameworks = unique([targets.Framework], "stable");

    optionTable = struct( ...
        "Name", {"PioPlatform", "PioBoard", "PioFramework", "PioExtraLibraries", ...
        "PioMonitorSpeed", "PioUpload", "PioTaskStackWords"}, ...
        "Prompt", {"PlatformIO platform", "PlatformIO board", "PlatformIO framework", ...
        "Extra libraries", "Serial monitor speed", "Upload after build", ...
        "FreeRTOS task stack (words)"}, ...
        "Type", {"Popup", "Popup", "Popup", "Edit", "Edit", "Checkbox", "Edit"}, ...
        "Default", {defaultTarget.Platform, defaultTarget.DisplayName, defaultTarget.Framework, ...
        defaultTarget.ExtraLibraries, "115200", "off", defaultTarget.TaskStackWords}, ...
        "PopupStrings", {joinPopup(platforms), joinPopup(boards), joinPopup(frameworks), ...
        "", "", "", ""}, ...
        "Callback", {"", "piofrtos.syncKnownTarget(hDlg, hSrc)", "", "", "", "", ""}, ...
        "TlcVariable", {"PioPlatform", "PioBoard", "PioFramework", "PioExtraLibraries", ...
        "PioMonitorSpeed", "PioUpload", "PioTaskStackWords"}, ...
        "MakeVariable", {"PIO_PLATFORM", "PIO_BOARD", "PIO_FRAMEWORK", "PIO_EXTRA_LIBRARIES", ...
        "PIO_MONITOR_SPEED", "PIO_UPLOAD", "PIO_TASK_STACK_WORDS"}, ...
        "Tooltip", { ...
        "PlatformIO platform. Selecting a board fills this in.", ...
        "Board. Selecting a board sets platform, framework, libraries, and stack.", ...
        "PlatformIO framework. Known-good AVR boards use arduino.", ...
        "Optional PlatformIO lib_deps entries. Separate libraries with commas or semicolons. " + ...
        "AVR boards need a FreeRTOS port such as feilipu/FreeRTOS.", ...
        "Baud rate passed to PlatformIO monitor_speed and Serial.begin.", ...
        "If selected, the generated makefile runs pio run -t upload after a successful build.", ...
        "Stack depth passed to xTaskCreate for each sample-rate task. On AVR this is words."});
end

function popup = joinPopup(values)
%JOINPOPUP - Join popup choice strings with "|" for rtwoptions.popupstrings.
%   Local helper for getOptionTable. Uses join(values, "|") so TLC generation
%   can emit a single popupstrings literal.
%
%   Syntax:
%       popup = joinPopup(values)
%
%   Inputs:
%       values - string array of popup entries (platforms, boards, or frameworks).
%
%   Outputs:
%       popup - string with entries separated by "|".
%
%   Example:
%       popup = joinPopup(["atmelavr", "espressif32"]);
%
%   See also: GETOPTIONTABLE
    popup = join(values, "|");
end
