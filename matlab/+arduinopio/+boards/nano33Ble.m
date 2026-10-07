function info = nano33Ble()
%NANO33BLE - Pin map for Arduino Nano 33 BLE Sense (nRF52840).
%   Starts from the Uno map, then sets nRF52 pins, PWM analogWrite, and
%   ArduinoBLE. This board has no DAC. Package path: arduinopio.boards.nano33Ble.
%
%   Syntax:
%       info = arduinopio.boards.nano33Ble()
%
%   Inputs:
%       none
%
%   Outputs:
%       info - struct. Implemented true, HasDac false, HasBle true, PwmPins 0:13.
%
%   Example:
%       info = arduinopio.boards.nano33Ble();
%
%   Other m-files required: arduinopio.boards.uno
%   Subfunctions: none
%   MAT-files required: none
%
%   See also: UNO, GETBOARD, LISTBOARDS

%   Author: Frey, Jed
%   07-Oct-2026; Last revision: 07-Oct-2026

%------------- BEGIN CODE --------------
    info = arduinopio.boards.uno();
    info.Name = "nano33Ble";
    info.DisplayName = "Arduino Nano 33 BLE Sense";
    info.Mcu = "nRF52840";
    info.Architecture = "nrf52";
    info.Implemented = true;
    info.DigitalPins = 0:21;
    info.AnalogPins = 0:7;
    info.AnalogAsDigitalPins = 14:21;
    info.PwmPins = 0:13;
    info.InterruptPins = 0:13;
    info.CapturePins = double.empty(1, 0);
    info.UartCount = 1;
    info.EepromSize = 0;
    info.AdcBits = 12;
    info.HasInputPulldown = true;
    info.HasDac = false;
    info.HasBle = true;
    info.HasMcp2515 = false;
    info.PwmTimers = struct("Pin", {}, "Timer", {}, "Channel", {});
    info.ExtraBlocks = ["PWM Analog Output", "BLE Transmit", "BLE Receive"];
    info.Notes = [ ...
        "nRF52840. There is no DAC. Analog output is analogWrite PWM, duty 0-255."
        "Analog pins A0-A7 are ADC channels 0-7."
        "BLE uses the ArduinoBLE library."
        "This board has no EEPROM."];
end
