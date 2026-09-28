function validateModelForTarget(modelName)
%VALIDATEMODELFORTARGET - Error if the model cannot use this target.
%   Checks that modelName uses a fixed-step solver, which the Arduino FreeRTOS
%   (PlatformIO) piofrtos target requires for deterministic discrete-rate
%   FreeRTOS tasks. Raises piofrtos:VariableStepNotSupported when SolverType
%   is not "Fixed-step". Call before code generation or main emission.
%
%   Syntax:
%       piofrtos.validateModelForTarget(modelName)
%
%   Inputs:
%       modelName - (1,1) string name of a loaded Simulink model. Must expose
%           the SolverType parameter via get_param.
%
%   Outputs:
%       none
%
%   Example:
%       % Abort early when the solver is incompatible with FreeRTOS tasks.
%       piofrtos.validateModelForTarget("blink");
%
%   Other m-files required: none
%   Subfunctions: none
%   MAT-files required: none
%
%   See also: CONFIGUREMODEL, GETMODELSAMPLERATES

%   Author: Frey, Jed
%   28-Sep-2026; Last revision: 28-Sep-2026

%------------- BEGIN CODE --------------
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
