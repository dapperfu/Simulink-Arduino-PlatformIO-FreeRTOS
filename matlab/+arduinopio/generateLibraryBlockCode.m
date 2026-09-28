function generateLibraryBlockCode(libraryBlockPath, workFolder)
%generateLibraryBlockCode Put a library block in a fixed-step model and generate code.

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
    tf = blockName == "External Interrupt" || blockName == "Hardware Interrupt AVR";
end

function [constantValue, dataType] = inputConstantForBlock(blockName)
    switch blockName
        case {"Serial Transmit", "I2C Write", "SPI WriteRead", "CAN Transmit", "EEPROM Write"}
            constantValue = "uint8(0)";
            dataType = "uint8";
        case {"External Interrupt", "Hardware Interrupt AVR"}
            constantValue = "0";
            dataType = "boolean";
        otherwise
            constantValue = "0";
            dataType = "double";
    end
end
