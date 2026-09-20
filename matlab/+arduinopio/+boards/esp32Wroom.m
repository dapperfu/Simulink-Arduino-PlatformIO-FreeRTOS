function info = esp32Wroom()
%esp32Wroom Stub capability data for ESP32-WROOM.

    info = arduinopio.boards.uno();
    info.Name = "esp32Wroom";
    info.DisplayName = "ESP32-WROOM";
    info.Mcu = "ESP32-D0WDQ6";
    info.Architecture = "xtensa";
    info.Implemented = false;
    info.HasDac = true;
    info.HasWifi = true;
    info.HasBle = true;
    info.EepromSize = 0;
    info.ExtraBlocks = ["Analog Output", "WiFi TCP/UDP", "BLE", "Touch Sense"];
end
