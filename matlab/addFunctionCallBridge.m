function addFunctionCallBridge(chartPath)
%ADDFUNCTIONCALLBRIDGE - Add a Stateflow chart that emits a function-call.
%   Inserts an sflib/Chart at chartPath, sets ActionLanguage to MATLAB, and
%   defines boolean input Pending plus function-call output event IRQ. A single
%   Poll state sends IRQ during each step when Pending is true. Used by
%   interrupt library subsystems to drive Function-Call Subsystems.
%
%   Syntax:
%       addFunctionCallBridge(chartPath)
%
%   Inputs:
%       chartPath - Full path for the Chart block (1x1 string)
%
%   Outputs:
%       none
%
%   Example:
%       addFunctionCallBridge(dest + "/Bridge");
%
%   Other m-files required: none
%   Subfunctions: none
%   MAT-files required: none
%
%   See also: CREATEARDUINOPIOLIBRARY

%   Author: Frey, Jed
%   28-Sep-2026; Last revision: 28-Sep-2026

%------------- BEGIN CODE --------------

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
