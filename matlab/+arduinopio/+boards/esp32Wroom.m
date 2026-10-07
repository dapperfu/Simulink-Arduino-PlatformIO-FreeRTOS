function info = esp32Wroom()
%ESP32WROOM - Pin map for ESP32-WROOM-32.
%   Starts from the Uno map, then sets GPIO numbers used by a WROOM dev module,
%   including DAC1/DAC2 and touch pads. analogRead and touchRead take the GPIO
%   number. Package path: arduinopio.boards.esp32Wroom.
%
%   Syntax:
%       info = arduinopio.boards.esp32Wroom()
%
%   Inputs:
%       none
%
%   Outputs:
%       info - struct. Implemented true, DacPins [25 26], TouchPins set,
%           HasWifi true, HasBle true.
%
%   Example:
%       info = arduinopio.boards.esp32Wroom();
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
    info.Name = "esp32Wroom";
    info.DisplayName = "ESP32-WROOM";
    info.Mcu = "ESP32-D0WDQ6";
    info.Architecture = "xtensa";
    info.Implemented = true;
    info.DigitalPins = [0, 2, 4, 5, 12:19, 21:23, 25:27, 32:39];
    info.AnalogPins = [0, 2, 4, 12:15, 25:27, 32:39];
    info.AnalogAsDigitalPins = double.empty(1, 0);
    info.PwmPins = [0, 2, 4, 5, 12:19, 21:23, 25:27, 32, 33];
    info.InterruptPins = info.DigitalPins;
    info.CapturePins = double.empty(1, 0);
    info.UartCount = 3;
    info.EepromSize = 0;
    info.AdcBits = 12;
    info.HasInputPulldown = true;
    info.HasDac = true;
    info.DacPins = [25, 26];
    info.DacBits = 8;
    info.TouchPins = [0, 2, 4, 12, 13, 14, 15, 27, 32, 33];
    info.HasWifi = true;
    info.HasBle = true;
    info.HasMcp2515 = false;
    info.BuiltinLedPin = 2;
    info.PwmTimers = struct("Pin", {}, "Timer", {}, "Channel", {});
    info.ExtraBlocks = ["DAC Write", "WiFi UDP", "WiFi TCP", "BLE", "Touch Read"];
    info.Notes = [ ...
        "ESP32-WROOM. Pin numbers are GPIO numbers."
        "DAC is GPIO 25 and GPIO 26, 8-bit dacWrite."
        "Touch pads are GPIO 0, 2, 4, 12-15, 27, 32, and 33."
        "GPIO 34-39 are input-only. WiFi and BLE are in the ESP32 Arduino core."
        "FreeRTOS is already running, so setup() does not call vTaskStartScheduler."];
end
