function blkStruct = slblocks
%slblocks Register the Arduino PIO FreeRTOS library in the Simulink Library Browser.

    Browser.Library = "arduinopio_lib";
    Browser.Name = "Arduino PIO FreeRTOS";
    Browser.IsFlat = 0;
    blkStruct.Browser = Browser;
end
