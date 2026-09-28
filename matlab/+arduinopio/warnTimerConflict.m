function warnTimerConflict(pin, usage)
%warnTimerConflict Warn when a Uno PWM/timer pin shares Timer1 with Servo or capture.

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
