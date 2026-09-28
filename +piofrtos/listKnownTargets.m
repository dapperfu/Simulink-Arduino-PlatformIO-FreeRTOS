function targets = listKnownTargets()
%LISTKNOWNTARGETS - Return PlatformIO targets known to work with this STF.
%   Defines the curated board list for the piofrtos Arduino FreeRTOS Simulink
%   target. Currently returns Arduino Uno (atmelavr/uno) and Arduino Nano
%   (atmelavr/nanoatmega328), both with framework arduino, ExtraLibraries
%   feilipu/FreeRTOS, and TaskStackWords "192". Consumed by getOptionTable,
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
        knownTarget("Arduino Uno", "atmelavr", "uno", "arduino")
        knownTarget("Arduino Nano", "atmelavr", "nanoatmega328", "arduino")];
end

function target = knownTarget(displayName, platform, board, framework)
%KNOWNTARGET - Build one known-good PlatformIO board struct for piofrtos.
%   Local constructor used by listKnownTargets. Sets ExtraLibraries to
%   "feilipu/FreeRTOS" and TaskStackWords to "192" for AVR FreeRTOS builds.
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
%       t = knownTarget("Arduino Uno", "atmelavr", "uno", "arduino");
%
%   See also: LISTKNOWNTARGETS
    target = struct( ...
        "DisplayName", string(displayName), ...
        "Platform", string(platform), ...
        "Board", string(board), ...
        "Framework", string(framework), ...
        "ExtraLibraries", "feilipu/FreeRTOS", ...
        "TaskStackWords", "192");
end
