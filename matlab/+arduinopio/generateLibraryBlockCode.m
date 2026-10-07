function generateLibraryBlockCode(libraryBlockPath, workFolder)
%GENERATELIBRARYBLOCKCODE - Place a library block in a fixed-step model and generate code.
%   Creates a temporary model with piofrtos.tlc, adds the library block as DUT,
%   wires Constant sources and Terminators (or a function-call subsystem for
%   interrupt blocks), then runs code-only build. Creates workFolder if needed.
%   Package path: arduinopio.generateLibraryBlockCode.
%
%   Syntax:
%       arduinopio.generateLibraryBlockCode(libraryBlockPath, workFolder)
%
%   Inputs:
%       libraryBlockPath - (1,1) string. Full path of a block in arduinopio_lib.
%       workFolder - (1,1) string. Folder created if missing; used as working dir.
%
%   Outputs:
%       none
%
%   Example:
%       arduinopio.generateLibraryBlockCode( ...
%           "arduinopio_lib/Digital/Digital Output", tempdir);
%
%   Other m-files required: none
%   Subfunctions: wireLibraryBlock, isInterruptBlock, inputConstantForBlock
%   MAT-files required: none
%
%   See also: LISTLIBRARYBLOCKS

%   Author: Frey, Jed
%   28-Sep-2026; Last revision: 28-Sep-2026

%------------- BEGIN CODE --------------
    arguments
        libraryBlockPath (1,1) string
        workFolder (1,1) string
    end

    if ~isfolder(workFolder)
        mkdir(workFolder);
    end

    modelName = "cg" + string(randi(1e9));
    new_system(modelName);
    load_system(modelName);
    closer = onCleanup(@() close_system(modelName, 0));

    set_param(modelName, ...
        SolverType="Fixed-step", ...
        Solver="FixedStepDiscrete", ...
        FixedStep="0.01", ...
        StopTime="0.02", ...
        EnableMultiTasking="on");
    set_param(modelName, SystemTargetFile="piofrtos.tlc");
    set_param(modelName, GenCodeOnly="on", MatFileLogging="off");

    dest = modelName + "/DUT";
    add_block(libraryBlockPath, dest, Position=[200, 80, 360, 150]);
    try
        set_param(dest, "SampleTime", "0.01");
    catch
        % Block has no SampleTime parameter.
    end

    wireLibraryBlock(modelName, dest, libraryBlockPath);
    evalc("slbuild(modelName, ""GenerateCodeOnly"", true)");
end

function wireLibraryBlock(modelName, blockPath, libraryBlockPath)
%WIRELIBRARYBLOCK - Connect Constant inputs and Terminators (or IRQ subsystem).
%   Uses the library block leaf name to choose Constant value and data type.
%   External Interrupt and Hardware Interrupt AVR get a Function-Call Subsystem
%   on the first outport instead of Terminators.
%
%   Syntax:
%       wireLibraryBlock(modelName, blockPath, libraryBlockPath)
%
%   Inputs:
%       modelName - string. Temporary model name.
%       blockPath - string. Path of the DUT block in the model.
%       libraryBlockPath - string. Original library path (leaf name used).
%
%   Outputs:
%       none
%
%   Example:
%       % Called from generateLibraryBlockCode after add_block.
%
%   See also: GENERATELIBRARYBLOCKCODE, ISINTERRUPTBLOCK, INPUTCONSTANTFORBLOCK
    pathParts = split(libraryBlockPath, "/");
    blockName = pathParts(end);
    portHandles = get_param(blockPath, "PortHandles");
    inputCount = numel(portHandles.Inport);
    outputCount = numel(portHandles.Outport);

    [constantValue, dataType] = inputConstantForBlock(blockName);
    for inputIndex = 1:inputCount
        sourceName = "u" + string(inputIndex);
        add_block("simulink/Sources/Constant", modelName + "/" + sourceName, ...
            Position=[40, 40 + (inputIndex-1)*40, 90, 70 + (inputIndex-1)*40]);
        set_param(modelName + "/" + sourceName, OutDataTypeStr=dataType, Value=constantValue);
        add_line(modelName, sourceName + "/1", "DUT/" + string(inputIndex));
    end

    if isInterruptBlock(blockName)
        add_block("simulink/Ports & Subsystems/Function-Call Subsystem", modelName + "/IRQFcn", ...
            Position=[430, 80, 560, 150]);
        destinationPorts = get_param(modelName + "/IRQFcn", "PortHandles");
        add_line(modelName, portHandles.Outport(1), destinationPorts.Trigger);
        return
    end

    for outputIndex = 1:outputCount
        sinkName = "y" + string(outputIndex);
        add_block("simulink/Sinks/Terminator", modelName + "/" + sinkName, ...
            Position=[430, 40 + (outputIndex-1)*40, 450, 60 + (outputIndex-1)*40]);
        add_line(modelName, "DUT/" + string(outputIndex), sinkName + "/1");
    end
end

function tf = isInterruptBlock(blockName)
%ISINTERRUPTBLOCK - True when the library leaf name is an interrupt block.
%   Matches "External Interrupt" or "Hardware Interrupt AVR".
%
%   Syntax:
%       tf = isInterruptBlock(blockName)
%
%   Inputs:
%       blockName - string. Leaf name of the library block path.
%
%   Outputs:
%       tf - logical. True for interrupt-style blocks that emit function-call.
%
%   Example:
%       tf = isInterruptBlock("External Interrupt");
%
%   See also: WIRELIBRARYBLOCK
    tf = blockName == "External Interrupt" || blockName == "Hardware Interrupt AVR";
end

function [constantValue, dataType] = inputConstantForBlock(blockName)
%INPUTCONSTANTFORBLOCK - Choose Constant Value and OutDataTypeStr for DUT inputs.
%   Serial/I2C/SPI/CAN/EEPROM Write use uint8(0). Interrupt blocks use boolean 0.
%   All other blocks use double 0.
%
%   Syntax:
%       [constantValue, dataType] = inputConstantForBlock(blockName)
%
%   Inputs:
%       blockName - string. Leaf name of the library block.
%
%   Outputs:
%       constantValue - char/string. Value parameter for the Constant block.
%       dataType - char/string. OutDataTypeStr for the Constant block.
%
%   Example:
%       [v, dt] = inputConstantForBlock("CAN Transmit");
%
%   See also: WIRELIBRARYBLOCK
    switch blockName
        case {"Serial Transmit", "I2C Write", "SPI WriteRead", "CAN Transmit", "EEPROM Write", ...
                "Serial 1 Transmit", "Serial 2 Transmit", "Serial 3 Transmit", ...
                "WiFi UDP Transmit", "WiFi TCP Transmit", "BLE Transmit", "Mega PWM", ...
                "PWM Analog Output"}
            constantValue = "uint8(0)";
            dataType = "uint8";
        case {"Onboard CAN Transmit"}
            constantValue = "uint8(zeros(8,1))";
            dataType = "uint8";
        case {"LED Matrix"}
            constantValue = "uint8(zeros(12,1))";
            dataType = "uint8";
        case {"DAC Write"}
            constantValue = "uint16(0)";
            dataType = "uint16";
        case {"External Interrupt", "Hardware Interrupt AVR"}
            constantValue = "0";
            dataType = "boolean";
        otherwise
            constantValue = "0";
            dataType = "double";
    end
end
