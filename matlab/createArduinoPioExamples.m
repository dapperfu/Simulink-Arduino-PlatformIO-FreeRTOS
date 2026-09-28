function createArduinoPioExamples()
%createArduinoPioExamples Create Uno example models that use the Common I/O blocks.

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
    resetModel(modelName, modelPath);
    piofrtos.configureModel(modelName, FixedStep=sampleTime);
end

function resetModel(modelName, modelPath)
    if bdIsLoaded(modelName)
        close_system(modelName, 0);
    end
    if isfile(modelPath)
        delete(modelPath);
    end
    new_system(modelName);
    load_system(modelName);
end
