function info = uno()
%uno Capability and pin map for Arduino Uno R3 (ATmega328P).

    info = struct();
    info.Name = "uno";
    info.DisplayName = "Arduino Uno R3";
    info.Mcu = "ATmega328P";
    info.Architecture = "avr";
    info.Implemented = true;
    info.DigitalPins = 0:19;
    info.AnalogPins = 0:5;
    info.AnalogAsDigitalPins = 14:19;
    info.PwmPins = [3, 5, 6, 9, 10, 11];
    info.InterruptPins = [2, 3];
    info.CapturePins = 8;
    info.SpiPins = struct("Ss", 10, "Mosi", 11, "Miso", 12, "Sck", 13);
    info.I2cPins = struct("Sda", 18, "Scl", 19);
    info.UartCount = 1;
    info.UartPins = struct("Rx", 0, "Tx", 1);
    info.EepromSize = 1024;
    info.AdcBits = 10;
    info.HasInputPulldown = false;
    info.HasDac = false;
    info.HasBle = false;
    info.HasWifi = false;
    info.HasOnboardCan = false;
    info.HasMcp2515 = true;
    info.HasLedMatrix = false;
    info.BuiltinLedPin = 13;
    info.PwmTimers = [ ...
        struct("Pin", 3, "Timer", 2, "Channel", "B"), ...
        struct("Pin", 5, "Timer", 0, "Channel", "B"), ...
        struct("Pin", 6, "Timer", 0, "Channel", "A"), ...
        struct("Pin", 9, "Timer", 1, "Channel", "A"), ...
        struct("Pin", 10, "Timer", 1, "Channel", "B"), ...
        struct("Pin", 11, "Timer", 2, "Channel", "A")];
    info.ExtraBlocks = string.empty(1, 0);
    info.Notes = [ ...
        "Classic Uno R3 / ATmega328P only."
        "Prefer a WDT FreeRTOS tick so Timer1 and Timer2 stay available for PWM."
        "Timer1 is shared by PWM pins 9/10, Servo, and Input Capture on D8."
        "CAN uses an MCP2515 on SPI. Default CS is pin 10; INT is unused because receive polls."];
end
