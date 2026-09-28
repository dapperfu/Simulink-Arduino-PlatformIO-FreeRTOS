function createArduinoPioExamples()
%CREATEARDUINOPIOEXAMPLES - Create Uno example models under examples/.
%   Ensures the examples folder exists under arduinopio.getRootFolder(), then
%   builds uno_blink, uno_analog_pwm, uno_serial, and uno_can using Common
%   MATLAB System I/O blocks configured for piofrtos via startExampleModel.
%   Also calls createMultirateExample with OpenModel=false so the multirate
%   demo is written without leaving the model open.
%
%   Syntax:
%       createArduinoPioExamples()
%
%   Inputs:
%       none
%
%   Outputs:
%       none
%
%   Example:
%       createArduinoPioExamples();
%
%   Other m-files required: arduinopio.getRootFolder, createMultirateExample,
%       piofrtos.configureModel
%   Subfunctions: createBlinkExample, createAnalogPwmExample,
%       createSerialExample, createCanExample, startExampleModel, resetModel
%   MAT-files required: none
%
%   See also: CREATEARDUINOPIOLIBRARY, BUILD_ALL, CREATEMULTIRATEEXAMPLE

%   Author: Frey, Jed
%   28-Sep-2026; Last revision: 28-Sep-2026

%------------- BEGIN CODE --------------

    rootDir = arduinopio.getRootFolder();
    exampleDir = fullfile(rootDir, "examples");
    if ~isfolder(exampleDir)
        mkdir(exampleDir);
    end

    createBlinkExample(exampleDir);
    createAnalogPwmExample(exampleDir);
    createSerialExample(exampleDir);
    createCanExample(exampleDir);
    createMultirateExample(OpenModel=false);
end

function createBlinkExample(exampleDir)
%CREATEBLINKEXAMPLE - Build examples/uno_blink.slx LED pulse demo.
%   Creates a 0.1 s fixed-step model with a sample-based Pulse Generator
%   (Period 10, PulseWidth 5) driving Digital Output on pin 13 via
%   arduinopio.blocks.common.DigitalOutput. Saves and closes the model.
%
%   Syntax:
%       createBlinkExample(exampleDir)
%
%   Inputs:
%       exampleDir - Folder path where uno_blink.slx is written
%
%   Outputs:
%       none
%
%   Example:
%       createBlinkExample(fullfile(arduinopio.getRootFolder(), "examples"));
%
%   See also: STARTEXAMPLEMODEL, CREATEARDUINOPIOEXAMPLES

    modelName = "uno_blink";
    modelPath = fullfile(exampleDir, modelName + ".slx");
    startExampleModel(modelName, modelPath, "0.1");

    add_block("simulink/Sources/Pulse Generator", modelName + "/Pulse", ...
        Position=[80, 80, 150, 120]);
    set_param(modelName + "/Pulse", PulseType="Sample based", Period="10", PulseWidth="5", SampleTime="0.1");

    add_block("simulink/User-Defined Functions/MATLAB System", modelName + "/Digital Output", ...
        Position=[220, 77, 340, 123]);
    set_param(modelName + "/Digital Output", System="arduinopio.blocks.common.DigitalOutput");
    set_param(modelName + "/Digital Output", Pin="13");
    set_param(modelName + "/Digital Output", SampleTime="0.1");

    add_line(modelName, "Pulse/1", "Digital Output/1");
    save_system(modelName, modelPath);
    close_system(modelName);
end

function createAnalogPwmExample(exampleDir)
%CREATEANALOGPWMEXAMPLE - Build examples/uno_analog_pwm.slx ADC-to-PWM demo.
%   Creates a 0.05 s fixed-step model reading Analog Input on pin 0, scaling
%   counts by 255/1023, and writing PWM on pin 5 via arduinopio.blocks.common
%   AnalogInput and Pwm System objects. Saves and closes the model.
%
%   Syntax:
%       createAnalogPwmExample(exampleDir)
%
%   Inputs:
%       exampleDir - Folder path where uno_analog_pwm.slx is written
%
%   Outputs:
%       none
%
%   Example:
%       createAnalogPwmExample(fullfile(arduinopio.getRootFolder(), "examples"));
%
%   See also: STARTEXAMPLEMODEL, CREATEBLINKEXAMPLE

    modelName = "uno_analog_pwm";
    modelPath = fullfile(exampleDir, modelName + ".slx");
    startExampleModel(modelName, modelPath, "0.05");

    add_block("simulink/User-Defined Functions/MATLAB System", modelName + "/Analog Input", ...
        Position=[80, 80, 200, 130]);
    set_param(modelName + "/Analog Input", System="arduinopio.blocks.common.AnalogInput");
    set_param(modelName + "/Analog Input", Pin="0");
    set_param(modelName + "/Analog Input", SampleTime="0.05");

    add_block("simulink/Math Operations/Gain", modelName + "/Scale", Position=[250, 87, 300, 123]);
    set_param(modelName + "/Scale", Gain="255/1023");

    add_block("simulink/User-Defined Functions/MATLAB System", modelName + "/PWM", ...
        Position=[360, 80, 470, 130]);
    set_param(modelName + "/PWM", System="arduinopio.blocks.common.Pwm");
    set_param(modelName + "/PWM", Pin="5");
    set_param(modelName + "/PWM", SampleTime="0.05");

    add_line(modelName, "Analog Input/1", "Scale/1");
    add_line(modelName, "Scale/1", "PWM/1");
    save_system(modelName, modelPath);
    close_system(modelName);
end

function createSerialExample(exampleDir)
%CREATESERIALEXAMPLE - Build examples/uno_serial.slx UART loopback demo.
%   Creates a 0.1 s fixed-step model that transmits uint8(65) on Serial Transmit
%   Port 0 at 9600 baud and receives one byte plus status from Serial Receive on
%   the same port. Receive outputs feed Terminator sinks. Saves and closes.
%
%   Syntax:
%       createSerialExample(exampleDir)
%
%   Inputs:
%       exampleDir - Folder path where uno_serial.slx is written
%
%   Outputs:
%       none
%
%   Example:
%       createSerialExample(fullfile(arduinopio.getRootFolder(), "examples"));
%
%   See also: STARTEXAMPLEMODEL, CREATECANEXAMPLE

    modelName = "uno_serial";
    modelPath = fullfile(exampleDir, modelName + ".slx");
    startExampleModel(modelName, modelPath, "0.1");

    add_block("simulink/Sources/Constant", modelName + "/TxData", Position=[80, 80, 140, 120]);
    set_param(modelName + "/TxData", Value="uint8(65)", OutDataTypeStr="uint8");

    add_block("simulink/User-Defined Functions/MATLAB System", modelName + "/Serial Transmit", ...
        Position=[200, 75, 340, 125]);
    set_param(modelName + "/Serial Transmit", System="arduinopio.blocks.common.SerialTransmit");
    set_param(modelName + "/Serial Transmit", Port="0");
    set_param(modelName + "/Serial Transmit", BaudRate="9600");
    set_param(modelName + "/Serial Transmit", SampleTime="0.1");

    add_block("simulink/User-Defined Functions/MATLAB System", modelName + "/Serial Receive", ...
        Position=[80, 180, 220, 250]);
    set_param(modelName + "/Serial Receive", System="arduinopio.blocks.common.SerialReceive");
    set_param(modelName + "/Serial Receive", Port="0");
    set_param(modelName + "/Serial Receive", BaudRate="9600");
    set_param(modelName + "/Serial Receive", DataLength="1");
    set_param(modelName + "/Serial Receive", SampleTime="0.1");

    add_block("simulink/Sinks/Terminator", modelName + "/DataTerm", Position=[280, 187, 300, 213]);
    add_block("simulink/Sinks/Terminator", modelName + "/StatusTerm", Position=[280, 227, 300, 253]);

    add_line(modelName, "TxData/1", "Serial Transmit/1");
    add_line(modelName, "Serial Receive/1", "DataTerm/1");
    add_line(modelName, "Serial Receive/2", "StatusTerm/1");
    save_system(modelName, modelPath);
    close_system(modelName);
end

function createCanExample(exampleDir)
%CREATECANEXAMPLE - Build examples/uno_can.slx MCP2515 CAN transmit/receive demo.
%   Creates a 0.05 s fixed-step model with CanTransmit and CanReceive System
%   objects in Interpreted execution, ChipSelectPin 10, 8 MHz oscillator,
%   500 kbps, MessageId 256 on transmit, OperatingMode 1, and terminators on
%   receive Id, Data, Len, and Status ports. Saves and closes the model.
%
%   Syntax:
%       createCanExample(exampleDir)
%
%   Inputs:
%       exampleDir - Folder path where uno_can.slx is written
%
%   Outputs:
%       none
%
%   Example:
%       createCanExample(fullfile(arduinopio.getRootFolder(), "examples"));
%
%   See also: STARTEXAMPLEMODEL, CREATESERIALEXAMPLE

    modelName = "uno_can";
    modelPath = fullfile(exampleDir, modelName + ".slx");
    startExampleModel(modelName, modelPath, "0.05");

    add_block("simulink/Sources/Constant", modelName + "/TxData", Position=[40, 80, 110, 120]);
    set_param(modelName + "/TxData", Value="uint8(1:8)", OutDataTypeStr="uint8");

    add_block("simulink/User-Defined Functions/MATLAB System", modelName + "/CAN Transmit", ...
        Position=[160, 72, 300, 128]);
    set_param(modelName + "/CAN Transmit", System="arduinopio.blocks.common.CanTransmit");
    set_param(modelName + "/CAN Transmit", SimulateUsing="Interpreted execution");
    set_param(modelName + "/CAN Transmit", ChipSelectPin="10");
    set_param(modelName + "/CAN Transmit", OscillatorMHz="8");
    set_param(modelName + "/CAN Transmit", BaudRateKbps="500");
    set_param(modelName + "/CAN Transmit", MessageId="256");
    set_param(modelName + "/CAN Transmit", OperatingMode="1");
    set_param(modelName + "/CAN Transmit", SampleTime="0.05");

    add_block("simulink/User-Defined Functions/MATLAB System", modelName + "/CAN Receive", ...
        Position=[160, 180, 300, 270]);
    set_param(modelName + "/CAN Receive", System="arduinopio.blocks.common.CanReceive");
    set_param(modelName + "/CAN Receive", SimulateUsing="Interpreted execution");
    set_param(modelName + "/CAN Receive", ChipSelectPin="10");
    set_param(modelName + "/CAN Receive", OscillatorMHz="8");
    set_param(modelName + "/CAN Receive", BaudRateKbps="500");
    set_param(modelName + "/CAN Receive", OperatingMode="1");
    set_param(modelName + "/CAN Receive", SampleTime="0.05");

    add_block("simulink/Sinks/Terminator", modelName + "/IdTerm", Position=[360, 187, 380, 213]);
    add_block("simulink/Sinks/Terminator", modelName + "/DataTerm", Position=[360, 217, 380, 243]);
    add_block("simulink/Sinks/Terminator", modelName + "/LenTerm", Position=[360, 247, 380, 273]);
    add_block("simulink/Sinks/Terminator", modelName + "/StatusTerm", Position=[360, 277, 380, 303]);

    add_line(modelName, "TxData/1", "CAN Transmit/1");
    add_line(modelName, "CAN Receive/1", "IdTerm/1");
    add_line(modelName, "CAN Receive/2", "DataTerm/1");
    add_line(modelName, "CAN Receive/3", "LenTerm/1");
    add_line(modelName, "CAN Receive/4", "StatusTerm/1");
    save_system(modelName, modelPath);
    close_system(modelName);
end

function startExampleModel(modelName, modelPath, sampleTime)
%STARTEXAMPLEMODEL - Reset a model and apply piofrtos fixed-step settings.
%   Calls resetModel to recreate modelName at modelPath, then
%   piofrtos.configureModel with FixedStep set to sampleTime so the example
%   targets the PlatformIO FreeRTOS system target file.
%
%   Syntax:
%       startExampleModel(modelName, modelPath, sampleTime)
%
%   Inputs:
%       modelName  - Simulink model name without extension
%       modelPath  - Full path to the .slx file
%       sampleTime - Fixed-step size string (for example "0.1")
%
%   Outputs:
%       none
%
%   Example:
%       startExampleModel("uno_blink", modelPath, "0.1");
%
%   See also: RESETMODEL, PIOFRTOS.CONFIGUREMODEL

    resetModel(modelName, modelPath);
    piofrtos.configureModel(modelName, FixedStep=sampleTime);
end

function resetModel(modelName, modelPath)
%RESETMODEL - Close, delete, and recreate an empty Simulink model file.
%   If modelName is loaded, closes without saving. Deletes modelPath when present,
%   then new_system and load_system so callers can add blocks to a clean model.
%
%   Syntax:
%       resetModel(modelName, modelPath)
%
%   Inputs:
%       modelName - Simulink model name
%       modelPath - Full path to the .slx to replace
%
%   Outputs:
%       none
%
%   Example:
%       resetModel("uno_blink", fullfile(exampleDir, "uno_blink.slx"));
%
%   See also: STARTEXAMPLEMODEL

    if bdIsLoaded(modelName)
        close_system(modelName, 0);
    end
    if isfile(modelPath)
        delete(modelPath);
    end
    new_system(modelName);
    load_system(modelName);
end
