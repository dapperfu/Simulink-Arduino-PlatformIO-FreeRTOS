function info = mega2560()
%mega2560 Stub capability data for Arduino Mega 2560. Drivers are not implemented yet.

    info = stubBoard("mega2560", "Arduino Mega 2560", "ATmega2560");
    info.DigitalPins = 0:69;
    info.AnalogPins = 0:15;
    info.PwmPins = [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13];
    info.UartCount = 4;
    info.EepromSize = 4096;
    info.Architecture = "avr";
    info.ExtraBlocks = ["Serial1", "Serial2", "Serial3"];
end

function info = stubBoard(name, displayName, mcu)
    info = arduinopio.boards.uno();
    info.Name = name;
    info.DisplayName = displayName;
    info.Mcu = mcu;
    info.Implemented = false;
end
