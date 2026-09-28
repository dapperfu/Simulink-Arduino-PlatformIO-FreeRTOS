function info = unoR4()
%unoR4 Stub capability data for Arduino Uno R4 Minima/WiFi (not classic Uno R3).

    info = arduinopio.boards.uno();
    info.Name = "unoR4";
    info.DisplayName = "Arduino Uno R4";
    info.Mcu = "RA4M1";
    info.Architecture = "renesas";
    info.Implemented = false;
    info.HasInputPulldown = true;
    info.HasDac = true;
    info.HasOnboardCan = true;
    info.HasLedMatrix = true;
    info.HasWifi = true;
    info.EepromSize = 0;
    info.ExtraBlocks = ["Analog Output", "On-board CAN", "12x8 LED Matrix", "WiFi (WiFi model)"];
end
