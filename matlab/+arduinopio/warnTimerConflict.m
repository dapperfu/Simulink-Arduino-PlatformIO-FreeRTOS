function warnTimerConflict(pin, usage)
%warnTimerConflict Warn when a Uno PWM/timer pin shares Timer1 with Servo or capture.

    arguments
        pin (1,1) {mustBeNumeric, mustBeInteger}
        usage (1,1) string
    end

    timerId = arduinopio.boards.timerForPwmPin(pin);
    if timerId == 1
        arduinopio.warnIfNotLibrary("arduinopio:Timer1Conflict", ...
            "%s on pin %d uses Timer1, which is also used by Servo and Input Capture on Uno.", ...
            usage, pin);
    end
end
