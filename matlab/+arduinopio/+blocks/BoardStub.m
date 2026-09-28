classdef (Sealed) BoardStub < matlab.System
    %BOARDSTUB - Placeholder that lists I/O not available on classic Uno R3.
    %   Sealed matlab.System (no coder.ExternalDependency). Nontunable BoardName
    %   defaults to "Later board"; ExtraBlocks defaults to "Not implemented".
    %   setupImpl and stepImpl are empty no-ops with zero ports. getIconImpl
    %   splits ExtraBlocks on commas, trims entries, drops empties, substitutes
    %   "Not implemented" when none remain, and builds an icon of BoardName,
    %   "Not implemented:", then up to six ExtraBlocks lines. Used as a
    %   library stub for boards whose unique I/O is not yet implemented.
    %
    %   Syntax:
    %       obj = arduinopio.blocks.BoardStub
    %       obj = arduinopio.blocks.BoardStub(Name=value)
    %
    %   Inputs:
    %       BoardName   - (1,1) string board label. Default: "Later board".
    %       ExtraBlocks - (1,1) string comma-separated stub list.
    %                     Default: "Not implemented".
    %
    %   Outputs:
    %       obj - BoardStub System object with no step ports.
    %
    %   Example:
    %       obj = arduinopio.blocks.BoardStub(BoardName="Due", ...
    %           ExtraBlocks="DAC, Native CAN");
    %
    %   Other m-files required: none
    %   Subfunctions: none
    %   MAT-files required: none
    %
    %   See also: IOREFERENCE

    %   Author: Frey, Jed
    %   28-Sep-2026; Last revision: 28-Sep-2026

    properties (Nontunable)
        BoardName (1,1) string = "Later board"
        ExtraBlocks (1,1) string = "Not implemented"
    end

    methods
        function obj = BoardStub(varargin)
        %BOARDSTUB - Construct a BoardStub System object from name-value pairs.
        %   Calls coder.allowpcode("plain") and setProperties for nontunable
        %   BoardName and ExtraBlocks.
        %
        %   Syntax:
        %       obj = BoardStub()
        %       obj = BoardStub(Name=value)
        %
        %   Inputs:
        %       varargin - Optional name-value pairs for nontunable properties.
        %
        %   Outputs:
        %       obj - Constructed BoardStub instance.
        %
        %   Example:
        %       obj = arduinopio.blocks.BoardStub(BoardName="Mega");
        %
        %   See also: GETICONIMPL

            coder.allowpcode("plain");
            setProperties(obj, nargin, varargin{:});
        end
    end

    methods (Access = protected)
        function setupImpl(~)
        %SETUPIMPL - No-op setup for the board stub placeholder.
        %   Performs no initialization; the stub has no hardware side effects.
        %
        %   Syntax:
        %       setupImpl(obj)
        %
        %   Inputs:
        %       ~ - Unused System object.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       % Invoked once before stepImpl during simulation.
        %
        %   See also: STEPIMPL
        end

        function stepImpl(~)
        %STEPIMPL - No-op step for the board stub placeholder.
        %   Performs no computation; the stub has zero input and output ports.
        %
        %   Syntax:
        %       stepImpl(obj)
        %
        %   Inputs:
        %       ~ - Unused System object.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       % Driven each sample by the Simulink System block.
        %
        %   See also: SETUPIMPL
        end

        function num = getNumInputsImpl(~)
        %GETNUMINPUTSIMPL - Report zero input ports for the board stub.
        %   Returns a fixed input count of 0.
        %
        %   Syntax:
        %       num = getNumInputsImpl(obj)
        %
        %   Inputs:
        %       ~ - Unused System object.
        %
        %   Outputs:
        %       num - Number of inputs (0).
        %
        %   Example:
        %       % Queried by the System object framework.
        %
        %   See also: GETNUMOUTPUTSIMPL

            num = 0;
        end

        function num = getNumOutputsImpl(~)
        %GETNUMOUTPUTSIMPL - Report zero output ports for the board stub.
        %   Returns a fixed output count of 0.
        %
        %   Syntax:
        %       num = getNumOutputsImpl(obj)
        %
        %   Inputs:
        %       ~ - Unused System object.
        %
        %   Outputs:
        %       num - Number of outputs (0).
        %
        %   Example:
        %       % Queried by the System object framework.
        %
        %   See also: GETNUMINPUTSIMPL

            num = 0;
        end

        function icon = getIconImpl(obj)
        %GETICONIMPL - Build a multi-line icon listing unimplemented I/O.
        %   Splits ExtraBlocks on ",", trims, drops empty entries, substitutes
        %   "Not implemented" when empty, then returns [BoardName;
        %   "Not implemented:"; extra(1:min(6,numel(extra)))].
        %
        %   Syntax:
        %       icon = getIconImpl(obj)
        %
        %   Inputs:
        %       obj - BoardStub System object.
        %
        %   Outputs:
        %       icon - String column for the Simulink block mask icon.
        %
        %   Example:
        %       % Queried when drawing the System block icon.
        %
        %   See also: BOARDSTUB

            extra = split(obj.ExtraBlocks, ",");
            extra = strtrim(extra);
            extra = extra(strlength(extra) > 0);
            if isempty(extra)
                extra = "Not implemented";
            end
            maxLines = min(6, numel(extra));
            icon = [obj.BoardName; "Not implemented:"; extra(1:maxLines)];
        end
    end
end
