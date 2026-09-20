function createArduinoPioLibrary()
%createArduinoPioLibrary Build libraries/arduinopio_lib.slx for the Library Browser.

    rootDir = arduinopio.getRootFolder();
    libDir = fullfile(rootDir, "libraries");
    if ~isfolder(libDir)
        mkdir(libDir);
    end
    libPath = fullfile(libDir, "arduinopio_lib.slx");
    libName = "arduinopio_lib";

    if bdIsLoaded(libName)
        close_system(libName, 0);
    end
    if isfile(libPath)
        delete(libPath);
    end

    new_system(libName, "Library");
    set_param(libName, "Lock", "off");

    addLibrarySubsystem(libName, "Common", [30, 30, 230, 80]);
    addLibrarySubsystem(libName, "Advanced AVR", [30, 110, 230, 160]);
    addLibrarySubsystem(libName, "Arduino Uno", [30, 190, 230, 240]);
    addLibrarySubsystem(libName, "Mega 2560", [270, 30, 470, 80]);
    addLibrarySubsystem(libName, "Due", [270, 110, 470, 160]);
    addLibrarySubsystem(libName, "MKR WiFi 1010", [270, 190, 470, 240]);
    addLibrarySubsystem(libName, "ESP32-WROOM", [510, 30, 710, 80]);
    addLibrarySubsystem(libName, "Uno R4", [510, 110, 710, 160]);
    addLibrarySubsystem(libName, "Nano 33 BLE", [510, 190, 710, 240]);

    common = libName + "/Common";
    addDigitalInputBlock(common, 1);
    addDigitalOutputBlock(common, 2);
    addAnalogInputBlock(common, 3);
    addAnalogOutputBlock(common, 4);
    addSerialReceiveBlock(common, 5);
    addSerialTransmitBlock(common, 6);
    addSystemBlock(common, "PWM", "arduinopio.blocks.common.Pwm", 7);
    addSystemBlock(common, "I2C Read", "arduinopio.blocks.common.I2cRead", 8);
    addSystemBlock(common, "I2C Write", "arduinopio.blocks.common.I2cWrite", 9);
    addSystemBlock(common, "SPI WriteRead", "arduinopio.blocks.common.SpiWriteRead", 10);
    addInterruptSubsystem(common, "External Interrupt", ...
        "arduinopio.blocks.common.ExternalInterrupt", "extint", 11);
    addSystemBlock(common, "Standard Servo Write", "arduinopio.blocks.common.StandardServoWrite", 12);
    addSystemBlock(common, "Standard Servo Read", "arduinopio.blocks.common.StandardServoRead", 13);
    addSystemBlock(common, "Continuous Servo Write", "arduinopio.blocks.common.ContinuousServoWrite", 14);
    addSystemBlock(common, "Encoder", "arduinopio.blocks.common.Encoder", 15);
    addSystemBlock(common, "Input Capture", "arduinopio.blocks.common.InputCapture", 16);
    addSystemBlock(common, "EEPROM Read", "arduinopio.blocks.common.EepromRead", 17);
    addSystemBlock(common, "EEPROM Write", "arduinopio.blocks.common.EepromWrite", 18);

    avr = libName + "/Advanced AVR";
    addSystemBlock(avr, "Analog Input AVR", "arduinopio.blocks.avr.AnalogInputAvr", 1);
    addSystemBlock(avr, "PWM AVR", "arduinopio.blocks.avr.PwmAvr", 2);
    addInterruptSubsystem(avr, "Hardware Interrupt AVR", ...
        "arduinopio.blocks.avr.HardwareInterruptAvr", "hwint", 3);

    addSystemBlock(libName + "/Arduino Uno", "Uno IO Reference", "arduinopio.blocks.uno.IoReference", 1);

    addStubBlock(libName + "/Mega 2560", "Mega 2560 extras", "Arduino Mega 2560", ...
        ["Serial1", "Serial2", "Serial3", "More PWM/ADC pins"]);
    addStubBlock(libName + "/Due", "Due extras", "Arduino Due", ...
        ["Analog Output (DAC)", "On-board CAN", "Serial1-3"]);
    addStubBlock(libName + "/MKR WiFi 1010", "MKR extras", "Arduino MKR WiFi 1010", ...
        ["Analog Output", "WiFi TCP/UDP", "BLE"]);
    addStubBlock(libName + "/ESP32-WROOM", "ESP32 extras", "ESP32-WROOM", ...
        ["Analog Output", "WiFi TCP/UDP", "BLE", "Touch Sense"]);
    addStubBlock(libName + "/Uno R4", "Uno R4 extras", "Arduino Uno R4", ...
        ["Analog Output", "On-board CAN", "12x8 LED Matrix", "WiFi (WiFi model)"]);
    addStubBlock(libName + "/Nano 33 BLE", "Nano 33 BLE extras", "Arduino Nano 33 BLE Sense", ...
        ["Analog Output", "BLE Receive", "BLE Transmit"]);

    save_system(libName, libPath);
    close_system(libName);
end

function addLibrarySubsystem(libName, name, position)
    add_block("built-in/Subsystem", libName + "/" + name, Position=position);
    innerBlocks = find_system(libName + "/" + name, LookUnderMasks="all", SearchDepth=1, Type="Block");
    for i = 1:numel(innerBlocks)
        blockPath = string(innerBlocks{i});
        if blockPath ~= (libName + "/" + name)
            delete_block(blockPath);
        end
    end
end

function addSystemBlock(parent, name, className, index)
    dest = parent + "/" + name;
    position = blockPosition(index);
    add_block("simulink/User-Defined Functions/MATLAB System", dest, Position=position);
    set_param(dest, "System", className);
end

function dest = addSFunctionBlock(parent, name, sfcnName, index, numericParameters)
    dest = parent + "/" + name;
    add_block("simulink/User-Defined Functions/Level-2 MATLAB S-Function", dest, ...
        Position=blockPosition(index), ...
        FunctionName=sfcnName, ...
        Parameters=numericParameters);
end

function addDigitalInputBlock(parent, index)
    dest = addSFunctionBlock(parent, "Digital Input", "arduinopio_digital_input", ...
        index, "2, 0, -1, 0");
    mask = Simulink.Mask.create(dest);
    mask.Type = "Arduino PIO Digital Input";
    mask.Description = "Read a digital pin. Uno pins 0-13 and A0-A5 (14-19) are valid.";
    mask.Display = "disp('Digital Input')";
    mask.addParameter(Type="edit", Name="Pin", Prompt="Pin number", Value="2");
    mask.addParameter(Type="checkbox", Name="EnablePullup", Prompt="Enable pull-up", Value="off");
    mask.addParameter(Type="edit", Name="SampleTime", Prompt="Sample time (-1 = inherited)", Value="-1");
    mask.addParameter(Type="edit", Name="SimValue", Prompt="Simulation output (0 or 1)", Value="0");
    mask.Initialization = "Pullup = double(strcmp(EnablePullup, 'on'));";
    set_param(dest, "Parameters", "Pin, Pullup, SampleTime, SimValue");
end

function addDigitalOutputBlock(parent, index)
    dest = addSFunctionBlock(parent, "Digital Output", "arduinopio_digital_output", ...
        index, "13, -1");
    mask = Simulink.Mask.create(dest);
    mask.Type = "Arduino PIO Digital Output";
    mask.Description = "Write a digital pin. Uno LED_BUILTIN is pin 13.";
    mask.Display = "disp('Digital Output')";
    mask.addParameter(Type="edit", Name="Pin", Prompt="Pin number", Value="13");
    mask.addParameter(Type="edit", Name="SampleTime", Prompt="Sample time (-1 = inherited)", Value="-1");
    set_param(dest, "Parameters", "Pin, SampleTime");
end

function addAnalogInputBlock(parent, index)
    dest = addSFunctionBlock(parent, "Analog Input", "arduinopio_analog_input", ...
        index, "0, -1, 0");
    mask = Simulink.Mask.create(dest);
    mask.Type = "Arduino PIO Analog Input";
    mask.Description = "Uno A0-A5 as pin 0-5. Output is 0-1023 for a 10-bit ADC.";
    mask.Display = "disp('Analog Input')";
    mask.addParameter(Type="edit", Name="Pin", Prompt="Analog pin (0 = A0)", Value="0");
    mask.addParameter(Type="edit", Name="SampleTime", Prompt="Sample time (-1 = inherited)", Value="-1");
    mask.addParameter(Type="edit", Name="SimValue", Prompt="Simulation ADC counts (0-1023)", Value="0");
    set_param(dest, "Parameters", "Pin, SampleTime, SimValue");
end

function addAnalogOutputBlock(parent, index)
    dest = addSFunctionBlock(parent, "Analog Output", "arduinopio_analog_output", ...
        index, "5, -1");
    mask = Simulink.Mask.create(dest);
    mask.Type = "Arduino PIO Analog Output";
    mask.Description = "Arduino analogWrite on a PWM pin. Input is 0-255. Uno PWM pins: 3, 5, 6, 9, 10, 11.";
    mask.Display = "disp('Analog Output')";
    mask.addParameter(Type="edit", Name="Pin", Prompt="PWM pin", Value="5");
    mask.addParameter(Type="edit", Name="SampleTime", Prompt="Sample time (-1 = inherited)", Value="-1");
    set_param(dest, "Parameters", "Pin, SampleTime");
end

function addSerialReceiveBlock(parent, index)
    dest = addSFunctionBlock(parent, "Serial Receive", "arduinopio_serial_receive", ...
        index, "0, 9600, 1, -1");
    mask = Simulink.Mask.create(dest);
    mask.Type = "Arduino PIO Serial Receive";
    mask.Description = "Read bytes from hardware UART. Uno uses Serial0 on pins 0 and 1.";
    mask.Display = "disp('Serial Receive')";
    mask.addParameter(Type="edit", Name="Port", Prompt="UART port index", Value="0");
    mask.addParameter(Type="edit", Name="BaudRate", Prompt="Baud rate", Value="9600");
    mask.addParameter(Type="edit", Name="DataLength", Prompt="Bytes per step", Value="1");
    mask.addParameter(Type="edit", Name="SampleTime", Prompt="Sample time (-1 = inherited)", Value="-1");
    set_param(dest, "Parameters", "Port, BaudRate, DataLength, SampleTime");
end

function addSerialTransmitBlock(parent, index)
    dest = addSFunctionBlock(parent, "Serial Transmit", "arduinopio_serial_transmit", ...
        index, "0, 9600, -1");
    mask = Simulink.Mask.create(dest);
    mask.Type = "Arduino PIO Serial Transmit";
    mask.Description = "Write uint8 bytes to hardware UART. Uno uses Serial0 on pins 0 and 1.";
    mask.Display = "disp('Serial Transmit')";
    mask.addParameter(Type="edit", Name="Port", Prompt="UART port index", Value="0");
    mask.addParameter(Type="edit", Name="BaudRate", Prompt="Baud rate", Value="9600");
    mask.addParameter(Type="edit", Name="SampleTime", Prompt="Sample time (-1 = inherited)", Value="-1");
    set_param(dest, "Parameters", "Port, BaudRate, SampleTime");
end

function addStubBlock(parent, name, boardName, extraBlocks)
    addSystemBlock(parent, name, "arduinopio.blocks.BoardStub", 1);
    dest = parent + "/" + name;
    set_param(dest, "BoardName", boardName);
    extraText = strjoin(extraBlocks, ",");
    set_param(dest, "ExtraBlocks", extraText);
end

function addInterruptSubsystem(parent, name, className, kind, index)
    dest = parent + "/" + name;
    add_block("built-in/Subsystem", dest, Position=blockPosition(index));
    innerBlocks = find_system(dest, LookUnderMasks="all", SearchDepth=1, Type="Block");
    for i = 1:numel(innerBlocks)
        blockPath = string(innerBlocks{i});
        if blockPath ~= dest
            delete_block(blockPath);
        end
    end

    add_block("simulink/Sources/In1", dest + "/SimIRQ", Position=[20, 52, 50, 68]);
    set_param(dest + "/SimIRQ", OutDataTypeStr="boolean");

    add_block("simulink/User-Defined Functions/MATLAB System", dest + "/Driver", ...
        Position=[80, 40, 200, 100]);
    set_param(dest + "/Driver", System=className);

    addFunctionCallBridge(dest + "/Bridge");
    add_block("simulink/Sinks/Out1", dest + "/IRQ", Position=[400, 62, 430, 78]);

    add_line(dest, "SimIRQ/1", "Driver/1");
    add_line(dest, "Driver/1", "Bridge/1");
    chartPh = get_param(dest + "/Bridge", "PortHandles");
    outPh = get_param(dest + "/IRQ", "PortHandles");
    add_line(dest, chartPh.Outport(1), outPh.Inport(1));

    mask = Simulink.Mask.create(dest);
    mask.Display = "disp('" + name + "')";
    if kind == "extint"
        mask.Type = "Arduino PIO External Interrupt";
        mask.Description = "Uno INT0/INT1 (pins 2 and 3). Connect IRQ to a Function-Call Subsystem. SimIRQ is simulation-only.";
        mask.addParameter(Type="edit", Name="Pin", Prompt="Pin number (Uno: 2 or 3)", Value="2");
        mask.addParameter(Type="edit", Name="Mode", Prompt="Mode (0=LOW, 1=CHANGE, 2=FALLING, 3=RISING)", Value="3");
        mask.addParameter(Type="checkbox", Name="EnablePullup", Prompt="Enable pull-up", Value="off");
        mask.Initialization = sprintf("%s\n%s\n%s", ...
            "set_param([gcb '/Driver'], 'Pin', Pin);", ...
            "set_param([gcb '/Driver'], 'Mode', Mode);", ...
            "set_param([gcb '/Driver'], 'EnablePullup', EnablePullup);");
    else
        mask.Type = "Arduino PIO Hardware Interrupt AVR";
        mask.Description = "0=Timer1 overflow, 1=Timer1 compare A, 2=Timer2 overflow, 3=ADC complete.";
        mask.addParameter(Type="edit", Name="SourceId", Prompt="SourceId (0=T1 ovf, 1=T1 cmpA, 2=T2 ovf, 3=ADC)", Value="0");
        mask.Initialization = "set_param([gcb '/Driver'], 'SourceId', SourceId);";
    end
end

function position = blockPosition(index)
    col = mod(index-1, 4);
    row = floor((index-1)/4);
    x = 40 + col*140;
    y = 40 + row*90;
    position = [x, y, x+110, y+60];
end
