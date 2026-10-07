function createArduinoPioLibrary()
%CREATEARDUINOPIOLIBRARY - Build the Arduino PIO FreeRTOS Simulink library.
%   Creates libraries/arduinopio_lib.slx under the toolbox root returned by
%   arduinopio.getRootFolder(). Closes and deletes any existing library of that
%   name, then adds subsystems for Common, Advanced AVR, Arduino Uno, Mega 2560,
%   Due, MKR WiFi 1010, ESP32-WROOM, Uno R4, Nano 33 BLE, and Digital IO Methods.
%   Common receives digital/analog/serial S-function masks, MATLAB System blocks
%   for PWM, I2C, SPI, servos, encoder, capture, EEPROM, and CAN, plus interrupt
%   subsystems. Board folders get masked MATLAB System drivers. Saves and closes the
%   library so slblocks can register it in the Library Browser.
%
%   Syntax:
%       createArduinoPioLibrary()
%
%   Inputs:
%       none
%
%   Outputs:
%       none
%
%   Example:
%       createArduinoPioLibrary();
%
%   Other m-files required: arduinopio.getRootFolder, addFunctionCallBridge,
%       arduinopio.maskDisplayWithPin, arduinopio.pinPullIndex,
%       arduinopio.pinPullNames
%   Subfunctions: addLibrarySubsystem, addSystemBlock, addSFunctionBlock,
%       addDigitalIoMethodLibrary, addSystemDigitalIoBlock, addCSfunctionBlock,
%       addCDigitalInputBlock, addCDigitalOutputBlock, addDigitalInputBlock,
%       addDigitalOutputBlock, addAnalogInputBlock, addAnalogOutputBlock,
%       addSerialReceiveBlock, addSerialTransmitBlock, addArduinoPioBoardBlocks,
%       addInterruptSubsystem, addInternalResistorParameter, blockPosition
%   MAT-files required: none
%
%   See also: CREATEARDUINOPIOEXAMPLES, BUILD_ALL, INSTALLARDUINOPIO, SLBLOCKS

%   Author: Frey, Jed
%   28-Sep-2026; Last revision: 28-Sep-2026

%------------- BEGIN CODE --------------

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
    addLibrarySubsystem(libName, "Digital IO Methods", [750, 30, 990, 80]);

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
    addSystemBlock(common, "CAN Transmit", "arduinopio.blocks.common.CanTransmit", 19);
    addSystemBlock(common, "CAN Receive", "arduinopio.blocks.common.CanReceive", 20);

    addDigitalIoMethodLibrary(libName + "/Digital IO Methods");

    avr = libName + "/Advanced AVR";
    addSystemBlock(avr, "Analog Input AVR", "arduinopio.blocks.avr.AnalogInputAvr", 1);
    addSystemBlock(avr, "PWM AVR", "arduinopio.blocks.avr.PwmAvr", 2);
    addInterruptSubsystem(avr, "Hardware Interrupt AVR", ...
        "arduinopio.blocks.avr.HardwareInterruptAvr", "hwint", 3);

    addSystemBlock(libName + "/Arduino Uno", "Uno IO Reference", "arduinopio.blocks.uno.IoReference", 1);
    addArduinoPioBoardBlocks(libName);

    save_system(libName, libPath);
    close_system(libName);
end

function addLibrarySubsystem(libName, name, position)
%ADDLIBRARYSUBSYSTEM - Add an empty subsystem at a fixed library position.
%   Inserts built-in/Subsystem as libName/name with the given Position vector,
%   then deletes every default inner block so the subsystem starts empty for
%   subsequent library block placement.
%
%   Syntax:
%       addLibrarySubsystem(libName, name, position)
%
%   Inputs:
%       libName  - Library model name (string or char)
%       name     - Subsystem name under the library
%       position - [left top right bottom] block Position
%
%   Outputs:
%       none
%
%   Example:
%       addLibrarySubsystem("arduinopio_lib", "Common", [30, 30, 230, 80]);
%
%   See also: ADDSYSTEMBLOCK, CREATEARDUINOPIOLIBRARY

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
%ADDSYSTEMBLOCK - Add a MATLAB System block bound to a System object class.
%   Places simulink/User-Defined Functions/MATLAB System at blockPosition(index)
%   under parent and sets the System parameter to className (for example
%   arduinopio.blocks.common.Pwm).
%
%   Syntax:
%       addSystemBlock(parent, name, className, index)
%
%   Inputs:
%       parent    - Parent system path (string)
%       name      - Block name under parent
%       className - Fully qualified System object class name
%       index     - One-based layout index for blockPosition
%
%   Outputs:
%       none
%
%   Example:
%       addSystemBlock(common, "PWM", "arduinopio.blocks.common.Pwm", 7);
%
%   See also: ADDSFUNCTIONBLOCK, BLOCKPOSITION

    dest = parent + "/" + name;
    position = blockPosition(index);
    add_block("simulink/User-Defined Functions/MATLAB System", dest, Position=position);
    set_param(dest, "System", className);
end

function dest = addSFunctionBlock(parent, name, sfcnName, index, numericParameters)
%ADDSFUNCTIONBLOCK - Add a Level-2 MATLAB S-Function library block.
%   Places a Level-2 MATLAB S-Function at blockPosition(index), sets
%   FunctionName to sfcnName, and Parameters to the numericParameters string
%   used as default dialog values before the mask is applied.
%
%   Syntax:
%       dest = addSFunctionBlock(parent, name, sfcnName, index, numericParameters)
%
%   Inputs:
%       parent            - Parent system path
%       name              - Block name
%       sfcnName          - M-file S-function name (for example
%                           arduinopio_digital_input)
%       index             - Layout index for blockPosition
%       numericParameters - Default Parameters string (for example "2, 0, -1, 0")
%
%   Outputs:
%       dest - Full path of the created block
%
%   Example:
%       dest = addSFunctionBlock(parent, "Digital Input", ...
%           "arduinopio_digital_input", 1, "2, 0, -1, 0");
%
%   See also: ADDDIGITALINPUTBLOCK, ADDSYSTEMBLOCK

    dest = parent + "/" + name;
    add_block("simulink/User-Defined Functions/Level-2 MATLAB S-Function", dest, ...
        Position=blockPosition(index), ...
        FunctionName=sfcnName, ...
        Parameters=numericParameters);
end

function addDigitalIoMethodLibrary(parent)
%ADDDIGITALIOMETHODLIBRARY - Populate Digital IO Methods comparison folders.
%   Under parent, creates Level-2 MATLAB S-Function, MATLAB System object, and
%   Level-2 C S-Function subsystems. Adds Digital Input/Output blocks for each
%   implementation so users can compare host simulation and codegen approaches.
%
%   Syntax:
%       addDigitalIoMethodLibrary(parent)
%
%   Inputs:
%       parent - Path to the Digital IO Methods subsystem
%
%   Outputs:
%       none
%
%   Example:
%       addDigitalIoMethodLibrary(libName + "/Digital IO Methods");
%
%   See also: ADDDIGITALINPUTBLOCK, ADDCDIGITALINPUTBLOCK, ADDSYSTEMDIGITALIOBLOCK

    addLibrarySubsystem(parent, "Level-2 MATLAB S-Function", [30, 30, 250, 80]);
    addLibrarySubsystem(parent, "MATLAB System object", [30, 110, 250, 160]);
    addLibrarySubsystem(parent, "Level-2 C S-Function", [30, 190, 250, 240]);

    level2Matlab = parent + "/Level-2 MATLAB S-Function";
    addDigitalInputBlock(level2Matlab, 1);
    addDigitalOutputBlock(level2Matlab, 2);

    systemObject = parent + "/MATLAB System object";
    addSystemDigitalIoBlock(systemObject, "Digital Input", ...
        "arduinopio.blocks.common.DigitalInput", 1);
    addSystemDigitalIoBlock(systemObject, "Digital Output", ...
        "arduinopio.blocks.common.DigitalOutput", 2);

    level2C = parent + "/Level-2 C S-Function";
    addCDigitalInputBlock(level2C, 1);
    addCDigitalOutputBlock(level2C, 2);
end

function addSystemDigitalIoBlock(parent, name, className, index)
%ADDSYSTEMDIGITALIOBLOCK - Add a MATLAB System digital I/O block for comparison.
%   Adds a MATLAB System block for DigitalInput or DigitalOutput and forces
%   SimulateUsing to Interpreted execution so the System object path runs without
%   code generation during library browsing and host simulation.
%
%   Syntax:
%       addSystemDigitalIoBlock(parent, name, className, index)
%
%   Inputs:
%       parent    - Parent subsystem path
%       name      - Block name such as "Digital Input"
%       className - System object class (DigitalInput or DigitalOutput)
%       index     - Layout index for blockPosition
%
%   Outputs:
%       none
%
%   Example:
%       addSystemDigitalIoBlock(systemObject, "Digital Input", ...
%           "arduinopio.blocks.common.DigitalInput", 1);
%
%   See also: ADDSYSTEMBLOCK, ADDDIGITALIOMETHODLIBRARY

    dest = parent + "/" + name;
    add_block("simulink/User-Defined Functions/MATLAB System", dest, ...
        Position=blockPosition(index));
    set_param(dest, "System", className);
    set_param(dest, "SimulateUsing", "Interpreted execution");
end

function dest = addCSfunctionBlock(parent, name, sfcnName, index, numericParameters)
%ADDCSFUNCTIONBLOCK - Add a Level-2 C S-Function block for digital I/O demos.
%   Places simulink/User-Defined Functions/S-Function with FunctionName set to
%   the mex S-function (for example arduinopio_digital_input_c) and default
%   Parameters from numericParameters. Callers typically wrap the result with a
%   mask that exposes Pin and SampleTime.
%
%   Syntax:
%       dest = addCSfunctionBlock(parent, name, sfcnName, index, numericParameters)
%
%   Inputs:
%       parent            - Parent subsystem path
%       name              - Block name
%       sfcnName          - C S-function mex name
%       index             - Layout index for blockPosition
%       numericParameters - Default Parameters string
%
%   Outputs:
%       dest - Full path of the created block
%
%   Example:
%       dest = addCSfunctionBlock(parent, "Digital Input", ...
%           "arduinopio_digital_input_c", 1, "2, 0, -1, 0");
%
%   See also: ADDCDIGITALINPUTBLOCK, BUILDARDUINOPIOSFUNCTIONS

    dest = parent + "/" + name;
    add_block("simulink/User-Defined Functions/S-Function", dest, ...
        Position=blockPosition(index), ...
        FunctionName=sfcnName, ...
        Parameters=numericParameters);
end

function addCDigitalInputBlock(parent, index)
%ADDCDIGITALINPUTBLOCK - Masked Level-2 C Digital Input library block.
%   Creates an S-Function using arduinopio_digital_input_c with defaults
%   Pin=2, PinPull=0, SampleTime=-1, SimValue=0. Mask type is Arduino PIO
%   Digital Input (Level-2 C). Parameters are Pin, InternalResistor (mapped to
%   PinPull via initialization), SampleTime, and SimValue. Requires a mex file
%   for simulation.
%
%   Syntax:
%       addCDigitalInputBlock(parent, index)
%
%   Inputs:
%       parent - Parent subsystem path
%       index  - Layout index for blockPosition
%
%   Outputs:
%       none
%
%   Example:
%       addCDigitalInputBlock(level2C, 1);
%
%   See also: ADDCDIGITALOUTPUTBLOCK, ADDINTERNALRESISTORPARAMETER

    dest = addCSfunctionBlock(parent, "Digital Input", "arduinopio_digital_input_c", ...
        index, "2, 0, -1, 0");
    mask = Simulink.Mask.create(dest);
    mask.Type = "Arduino PIO Digital Input (Level-2 C)";
    mask.Description = "Level-2 C S-function. Output is boolean. Mex file required for simulation.";
    mask.Display = arduinopio.maskDisplayWithPin("Digital Input C");
    mask.addParameter(Type="edit", Name="Pin", Prompt="Pin number", Value="2");
    addInternalResistorParameter(mask);
    mask.addParameter(Type="edit", Name="SampleTime", Prompt="Sample time (-1 = inherited)", Value="-1");
    mask.addParameter(Type="edit", Name="SimValue", Prompt="Simulation output (0 or 1)", Value="0");
    mask.Initialization = "PinPull = arduinopio.pinPullIndex(InternalResistor);";
    set_param(dest, "Parameters", "Pin, PinPull, SampleTime, SimValue");
end

function addCDigitalOutputBlock(parent, index)
%ADDCDIGITALOUTPUTBLOCK - Masked Level-2 C Digital Output library block.
%   Creates an S-Function using arduinopio_digital_output_c with defaults
%   Pin=13 and SampleTime=-1. Mask type is Arduino PIO Digital Output
%   (Level-2 C). Exposes Pin and SampleTime. Requires a mex file for simulation.
%
%   Syntax:
%       addCDigitalOutputBlock(parent, index)
%
%   Inputs:
%       parent - Parent subsystem path
%       index  - Layout index for blockPosition
%
%   Outputs:
%       none
%
%   Example:
%       addCDigitalOutputBlock(level2C, 2);
%
%   See also: ADDCDIGITALINPUTBLOCK, ADDDIGITALOUTPUTBLOCK

    dest = addCSfunctionBlock(parent, "Digital Output", "arduinopio_digital_output_c", ...
        index, "13, -1");
    mask = Simulink.Mask.create(dest);
    mask.Type = "Arduino PIO Digital Output (Level-2 C)";
    mask.Description = "Level-2 C S-function. Input is double. Mex file required for simulation.";
    mask.Display = arduinopio.maskDisplayWithPin("Digital Output C");
    mask.addParameter(Type="edit", Name="Pin", Prompt="Pin number", Value="13");
    mask.addParameter(Type="edit", Name="SampleTime", Prompt="Sample time (-1 = inherited)", Value="-1");
    set_param(dest, "Parameters", "Pin, SampleTime");
end

function addDigitalInputBlock(parent, index)
%ADDDIGITALINPUTBLOCK - Masked Level-2 MATLAB Digital Input library block.
%   Adds arduinopio_digital_input with defaults Pin=2, PinPull=0, SampleTime=-1,
%   SimValue=0. Mask type Arduino PIO Digital Input exposes Pin, InternalResistor
%   (converted to PinPull), SampleTime, and SimValue for host simulation.
%
%   Syntax:
%       addDigitalInputBlock(parent, index)
%
%   Inputs:
%       parent - Parent subsystem path
%       index  - Layout index for blockPosition
%
%   Outputs:
%       none
%
%   Example:
%       addDigitalInputBlock(common, 1);
%
%   See also: ARDUINOPIO_DIGITAL_INPUT, ADDINTERNALRESISTORPARAMETER

    dest = addSFunctionBlock(parent, "Digital Input", "arduinopio_digital_input", ...
        index, "2, 0, -1, 0");
    mask = Simulink.Mask.create(dest);
    mask.Type = "Arduino PIO Digital Input";
    mask.Description = "Read a digital pin. Internal resistor: None, Pull-up, or Pull-down.";
    mask.Display = arduinopio.maskDisplayWithPin("Digital Input");
    mask.addParameter(Type="edit", Name="Pin", Prompt="Pin number", Value="2");
    addInternalResistorParameter(mask);
    mask.addParameter(Type="edit", Name="SampleTime", Prompt="Sample time (-1 = inherited)", Value="-1");
    mask.addParameter(Type="edit", Name="SimValue", Prompt="Simulation output (0 or 1)", Value="0");
    mask.Initialization = "PinPull = arduinopio.pinPullIndex(InternalResistor);";
    set_param(dest, "Parameters", "Pin, PinPull, SampleTime, SimValue");
end

function addDigitalOutputBlock(parent, index)
%ADDDIGITALOUTPUTBLOCK - Masked Level-2 MATLAB Digital Output library block.
%   Adds arduinopio_digital_output with defaults Pin=13 and SampleTime=-1. Mask
%   type Arduino PIO Digital Output documents Uno LED_BUILTIN on pin 13 and
%   exposes Pin and SampleTime dialog parameters.
%
%   Syntax:
%       addDigitalOutputBlock(parent, index)
%
%   Inputs:
%       parent - Parent subsystem path
%       index  - Layout index for blockPosition
%
%   Outputs:
%       none
%
%   Example:
%       addDigitalOutputBlock(common, 2);
%
%   See also: ARDUINOPIO_DIGITAL_OUTPUT, ADDDIGITALINPUTBLOCK

    dest = addSFunctionBlock(parent, "Digital Output", "arduinopio_digital_output", ...
        index, "13, -1");
    mask = Simulink.Mask.create(dest);
    mask.Type = "Arduino PIO Digital Output";
    mask.Description = "Write a digital pin. Uno LED_BUILTIN is pin 13.";
    mask.Display = arduinopio.maskDisplayWithPin("Digital Output");
    mask.addParameter(Type="edit", Name="Pin", Prompt="Pin number", Value="13");
    mask.addParameter(Type="edit", Name="SampleTime", Prompt="Sample time (-1 = inherited)", Value="-1");
    set_param(dest, "Parameters", "Pin, SampleTime");
end

function addAnalogInputBlock(parent, index)
%ADDANALOGINPUTBLOCK - Masked Level-2 MATLAB Analog Input library block.
%   Adds arduinopio_analog_input with defaults Pin=0, SampleTime=-1, SimValue=0.
%   Mask type Arduino PIO Analog Input maps Uno A0-A5 as pins 0-5 and documents
%   a 0-1023 ADC count output for host simulation via SimValue.
%
%   Syntax:
%       addAnalogInputBlock(parent, index)
%
%   Inputs:
%       parent - Parent subsystem path
%       index  - Layout index for blockPosition
%
%   Outputs:
%       none
%
%   Example:
%       addAnalogInputBlock(common, 3);
%
%   See also: ARDUINOPIO_ANALOG_INPUT, ADDANALOGOUTPUTBLOCK

    dest = addSFunctionBlock(parent, "Analog Input", "arduinopio_analog_input", ...
        index, "0, -1, 0");
    mask = Simulink.Mask.create(dest);
    mask.Type = "Arduino PIO Analog Input";
    mask.Description = "Uno A0-A5 as pin 0-5. Output is 0-1023 for a 10-bit ADC.";
    mask.Display = arduinopio.maskDisplayWithPin("Analog Input");
    mask.addParameter(Type="edit", Name="Pin", Prompt="Analog pin (0 = A0)", Value="0");
    mask.addParameter(Type="edit", Name="SampleTime", Prompt="Sample time (-1 = inherited)", Value="-1");
    mask.addParameter(Type="edit", Name="SimValue", Prompt="Simulation ADC counts (0-1023)", Value="0");
    set_param(dest, "Parameters", "Pin, SampleTime, SimValue");
end

function addAnalogOutputBlock(parent, index)
%ADDANALOGOUTPUTBLOCK - Masked Level-2 MATLAB Analog Output (PWM) library block.
%   Adds arduinopio_analog_output with defaults Pin=5 and SampleTime=-1. Mask
%   type Arduino PIO Analog Output documents analogWrite duty 0-255 and Uno PWM
%   pins 3, 5, 6, 9, 10, and 11.
%
%   Syntax:
%       addAnalogOutputBlock(parent, index)
%
%   Inputs:
%       parent - Parent subsystem path
%       index  - Layout index for blockPosition
%
%   Outputs:
%       none
%
%   Example:
%       addAnalogOutputBlock(common, 4);
%
%   See also: ARDUINOPIO_ANALOG_OUTPUT, ADDANALOGINPUTBLOCK

    dest = addSFunctionBlock(parent, "Analog Output", "arduinopio_analog_output", ...
        index, "5, -1");
    mask = Simulink.Mask.create(dest);
    mask.Type = "Arduino PIO Analog Output";
    mask.Description = "Arduino analogWrite on a PWM pin. Input is 0-255. Uno PWM pins: 3, 5, 6, 9, 10, 11.";
    mask.Display = arduinopio.maskDisplayWithPin("Analog Output");
    mask.addParameter(Type="edit", Name="Pin", Prompt="PWM pin", Value="5");
    mask.addParameter(Type="edit", Name="SampleTime", Prompt="Sample time (-1 = inherited)", Value="-1");
    set_param(dest, "Parameters", "Pin, SampleTime");
end

function addSerialReceiveBlock(parent, index)
%ADDSERIALRECEIVEBLOCK - Masked Level-2 MATLAB Serial Receive library block.
%   Adds arduinopio_serial_receive with defaults Port=0, BaudRate=9600,
%   DataLength=1, SampleTime=-1. Mask type Arduino PIO Serial Receive exposes
%   Port, BaudRate, DataLength, and SampleTime for UART byte reads.
%
%   Syntax:
%       addSerialReceiveBlock(parent, index)
%
%   Inputs:
%       parent - Parent subsystem path
%       index  - Layout index for blockPosition
%
%   Outputs:
%       none
%
%   Example:
%       addSerialReceiveBlock(common, 5);
%
%   See also: ARDUINOPIO_SERIAL_RECEIVE, ADDSERIALTRANSMITBLOCK

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
%ADDSERIALTRANSMITBLOCK - Masked Level-2 MATLAB Serial Transmit library block.
%   Adds arduinopio_serial_transmit with defaults Port=0, BaudRate=9600, and
%   SampleTime=-1. Mask type Arduino PIO Serial Transmit exposes Port, BaudRate,
%   and SampleTime for uint8 UART writes on Serial0 pins 0 and 1 for Uno.
%
%   Syntax:
%       addSerialTransmitBlock(parent, index)
%
%   Inputs:
%       parent - Parent subsystem path
%       index  - Layout index for blockPosition
%
%   Outputs:
%       none
%
%   Example:
%       addSerialTransmitBlock(common, 6);
%
%   See also: ARDUINOPIO_SERIAL_TRANSMIT, ADDSERIALRECEIVEBLOCK

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

function addInterruptSubsystem(parent, name, className, kind, index)
%ADDINTERRUPTSUBSYSTEM - Build a masked interrupt driver with function-call IRQ.
%   Creates an empty subsystem containing SimIRQ (boolean Inport), a MATLAB
%   System Driver of className, a Stateflow Bridge from addFunctionCallBridge,
%   and an IRQ Outport. For kind "extint", promotes Pin, Mode, and PinPull from
%   Driver. Otherwise promotes SourceId for AVR hardware interrupt sources.
%
%   Syntax:
%       addInterruptSubsystem(parent, name, className, kind, index)
%
%   Inputs:
%       parent    - Parent subsystem path
%       name      - Subsystem and mask display name
%       className - Driver System object class
%       kind      - "extint" for external interrupt, otherwise AVR hwint
%       index     - Layout index for blockPosition
%
%   Outputs:
%       none
%
%   Example:
%       addInterruptSubsystem(common, "External Interrupt", ...
%           "arduinopio.blocks.common.ExternalInterrupt", "extint", 11);
%
%   See also: ADDFUNCTIONCALLBRIDGE, ADDSYSTEMBLOCK

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
    if kind == "extint"
        mask.Display = arduinopio.maskDisplayWithPin(name);
        mask.Type = "Arduino PIO External Interrupt";
        mask.Description = "Uno INT0/INT1 (pins 2 and 3). Internal resistor: None, Pull-up, or Pull-down. Connect IRQ to a Function-Call Subsystem. SimIRQ is simulation-only.";
        mask.addParameter(Type="promote", TypeOptions={"Driver/Pin"}, Name="Pin", ...
            Prompt="Pin number (Uno: 2 or 3)");
        mask.addParameter(Type="promote", TypeOptions={"Driver/Mode"}, Name="Mode", ...
            Prompt="Mode (0=LOW, 1=CHANGE, 2=FALLING, 3=RISING)");
        mask.addParameter(Type="promote", TypeOptions={"Driver/PinPull"}, Name="PinPull", ...
            Prompt="Internal resistor");
    else
        mask.Display = "disp('" + name + "')";
        mask.Type = "Arduino PIO Hardware Interrupt AVR";
        mask.Description = "0=Timer1 overflow, 1=Timer1 compare A, 2=Timer2 overflow, 3=ADC complete.";
        mask.addParameter(Type="promote", TypeOptions={"Driver/SourceId"}, Name="SourceId", ...
            Prompt="SourceId (0=T1 ovf, 1=T1 cmpA, 2=T2 ovf, 3=ADC)");
    end
end

function addInternalResistorParameter(mask)
%ADDINTERNALRESISTORPARAMETER - Add InternalResistor popup to a digital mask.
%   Creates a non-evaluating popup named InternalResistor whose TypeOptions come
%   from arduinopio.pinPullNames(), defaulting to the first name. Mask
%   Initialization typically maps the selection to PinPull via pinPullIndex.
%
%   Syntax:
%       addInternalResistorParameter(mask)
%
%   Inputs:
%       mask - Simulink.Mask handle already created for the block
%
%   Outputs:
%       none
%
%   Example:
%       addInternalResistorParameter(mask);
%
%   See also: ADDDIGITALINPUTBLOCK, ADDCDIGITALINPUTBLOCK

    names = cellstr(arduinopio.pinPullNames());
    parameter = mask.addParameter(Type="popup", Name="InternalResistor", Prompt="Internal resistor");
    parameter.TypeOptions = names;
    parameter.Evaluate = "off";
    parameter.Value = names{1};
end

function position = blockPosition(index)
%BLOCKPOSITION - Compute a four-column library grid Position from an index.
%   Maps one-based index to a 4-column grid with 140-pixel horizontal spacing and
%   90-pixel vertical spacing. Each block is 110 by 60 pixels, starting at
%   origin (40, 40). Used by addSystemBlock and the masked S-function helpers.
%
%   Syntax:
%       position = blockPosition(index)
%
%   Inputs:
%       index - One-based block layout index
%
%   Outputs:
%       position - [left top right bottom] Position vector
%
%   Example:
%       position = blockPosition(7);
%
%   See also: ADDSYSTEMBLOCK, ADDSFUNCTIONBLOCK

    col = mod(index-1, 4);
    row = floor((index-1)/4);
    x = 40 + col*140;
    y = 40 + row*90;
    position = [x, y, x+110, y+60];
end
