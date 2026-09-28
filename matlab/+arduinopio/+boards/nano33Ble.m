function info = nano33Ble()
%nano33Ble Stub capability data for Arduino Nano 33 BLE Sense.

    info = arduinopio.boards.uno();
    info.Name = "nano33Ble";
    info.DisplayName = "Arduino Nano 33 BLE Sense";
    info.Mcu = "nRF52840";
    info.Architecture = "nrf52";
    info.Implemented = false;
    info.HasInputPulldown = true;
    info.HasDac = true;
    info.HasBle = true;
    info.EepromSize = 0;
    info.ExtraBlocks = ["Analog Output", "BLE Receive", "BLE Transmit"];
end
