function validateModelForTarget(modelName)
%validateModelForTarget Error if the model cannot use this target.
    arguments
        modelName (1,1) string
    end

    solverType = string(get_param(modelName, "SolverType"));
    if solverType ~= "Fixed-step"
        error("piofrtos:VariableStepNotSupported", ...
            "Model %s uses a variable-step solver. " + ...
            "The Arduino FreeRTOS (PlatformIO) target requires a fixed-step solver.", ...
            modelName);
    end
end
