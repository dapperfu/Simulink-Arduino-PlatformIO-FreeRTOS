function info = due()
%due Stub capability data for Arduino Due. Drivers are not implemented yet.

    info = arduinopio.boards.uno();
    info.Name = "due";
    info.DisplayName = "Arduino Due";
    info.Mcu = "AT91SAM3X8E";
    info.Architecture = "sam";
    info.Implemented = false;
    info.HasDac = true;
    info.UartCount = 4;
    info.EepromSize = 0;
    info.HasOnboardCan = true;
    info.ExtraBlocks = ["Analog Output", "On-board CAN Receive", "On-board CAN Transmit", "Serial1-3"];
end
