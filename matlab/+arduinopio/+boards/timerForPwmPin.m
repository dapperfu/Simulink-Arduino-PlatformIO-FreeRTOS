function timerId = timerForPwmPin(pin)
%timerForPwmPin Return the Uno timer index for a PWM pin, or -1 if none.

    arguments
        pin (1,1) {mustBeNumeric, mustBeInteger}
    end

    switch pin
        case {5, 6}
            timerId = 0;
        case {9, 10}
            timerId = 1;
        case {3, 11}
            timerId = 2;
        otherwise
            timerId = -1;
    end
end
