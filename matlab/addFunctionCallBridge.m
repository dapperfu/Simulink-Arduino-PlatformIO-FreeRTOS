function addFunctionCallBridge(chartPath)
%addFunctionCallBridge Add a Stateflow chart that turns a boolean into a function-call.

    arguments
        chartPath (1,1) string
    end

    add_block("sflib/Chart", chartPath, Position=[240, 40, 360, 120]);
    rt = sfroot;
    chart = find(rt, "-isa", "Stateflow.Chart", "Path", char(chartPath));
    chart.ActionLanguage = "MATLAB";

    inData = Stateflow.Data(chart);
    inData.Name = "Pending";
    inData.Scope = "Input";
    inData.DataType = "boolean";

    eventOut = Stateflow.Event(chart);
    eventOut.Name = "IRQ";
    eventOut.Scope = "Output";
    eventOut.Trigger = "Function call";

    state = Stateflow.State(chart);
    state.Position = [40, 40, 180, 90];
    state.LabelString = sprintf("Poll\nduring:\n  if Pending\n    send(IRQ);\n  end");
end
