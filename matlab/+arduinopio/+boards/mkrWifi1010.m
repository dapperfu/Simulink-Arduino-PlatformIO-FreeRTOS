function info = mkrWifi1010()
%mkrWifi1010 Stub capability data for Arduino MKR WiFi 1010.

    info = arduinopio.boards.uno();
    info.Name = "mkrWifi1010";
    info.DisplayName = "Arduino MKR WiFi 1010";
    info.Mcu = "SAMD21";
    info.Architecture = "samd";
    info.Implemented = false;
    info.HasInputPulldown = true;
    info.HasDac = true;
    info.HasWifi = true;
    info.HasBle = true;
    info.EepromSize = 0;
    info.ExtraBlocks = ["Analog Output", "WiFi TCP/UDP", "BLE Receive", "BLE Transmit"];
end
