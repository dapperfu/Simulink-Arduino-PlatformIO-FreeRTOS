function buildDir = getBuildDirectory(modelName)
%getBuildDirectory Return the code generation folder for a model.
    arguments
        modelName (1,1) string
    end

    buildInfo = RTW.getBuildDir(modelName);
    buildDir = string(buildInfo.BuildDirectory);
end
