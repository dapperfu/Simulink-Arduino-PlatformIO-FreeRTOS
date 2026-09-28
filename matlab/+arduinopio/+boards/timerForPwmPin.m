function timerId = timerForPwmPin(pin)
%TIMERFORPWMPIN - Return the Uno timer index for a PWM pin, or -1 if none.
%   Maps classic Uno/Nano PWM pins to Timer0, Timer1, or Timer2. Used for
%   Timer1 conflict warnings with Servo and Input Capture. Package path:
%   arduinopio.boards.timerForPwmPin.
%
%   Syntax:
%       timerId = arduinopio.boards.timerForPwmPin(pin)
%
%   Inputs:
%       pin - (1,1) integer. Digital PWM pin number.
%
%   Outputs:
%       timerId - double. 0 for pins 5 and 6; 1 for pins 9 and 10; 2 for pins
%           3 and 11; -1 if the pin is not a mapped Uno PWM pin.
%
%   Example:
%       t = arduinopio.boards.timerForPwmPin(9);
%
%   Other m-files required: none
%   Subfunctions: none
%   MAT-files required: none
%
%   See also: UNO, WARNTIMERCONFLICT

%   Author: Frey, Jed
%   28-Sep-2026; Last revision: 28-Sep-2026

%------------- BEGIN CODE --------------
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
