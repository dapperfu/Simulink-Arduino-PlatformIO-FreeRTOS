function warnTimerConflict(pin, usage)
%WARNTIMERCONFLICT - Warn when a Uno PWM/timer pin shares Timer1 with Servo/capture.
%   Looks up the pin via timerForPwmPin. If Timer1 is used, issues a warning
%   through warnIfNotLibrary (skipped in library diagrams and during codegen).
%   Package path: arduinopio.warnTimerConflict.
%
%   Syntax:
%       arduinopio.warnTimerConflict(pin, usage)
%
%   Inputs:
%       pin - (1,1) integer. PWM pin to check.
%       usage - text scalar. Short description included in the warning message.
%
%   Outputs:
%       none
%
%   Example:
%       arduinopio.warnTimerConflict(9, "PWM");
%
%   Other m-files required: arduinopio.boards.timerForPwmPin,
%       arduinopio.warnIfNotLibrary
%   Subfunctions: none
%   MAT-files required: none
%
%   See also: TIMERFORPWMPIN, WARNIFNOTLIBRARY

%   Author: Frey, Jed
%   28-Sep-2026; Last revision: 28-Sep-2026

%------------- BEGIN CODE --------------
    arguments
        pin (1,1) {mustBeNumeric, mustBeInteger}
        usage {mustBeTextScalar}
    end

    timerId = arduinopio.boards.timerForPwmPin(pin);
    if timerId == 1
        messageText = string(usage) + " on pin " + string(pin) + ...
            " uses Timer1, which is also used by Servo and Input Capture on Uno.";
        arduinopio.warnIfNotLibrary("arduinopio:Timer1Conflict", messageText);
    end
end
