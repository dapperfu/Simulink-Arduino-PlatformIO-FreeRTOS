classdef (Sealed) BoardStub < matlab.System
    %BoardStub Placeholder that lists I/O not available on classic Uno R3.

    properties (Nontunable)
        BoardName (1,1) string = "Later board"
        ExtraBlocks (1,:) string = "Not implemented"
    end

    methods
        function obj = BoardStub(varargin)
            coder.allowpcode("plain");
            setProperties(obj, nargin, varargin{:});
        end
    end

    methods (Access = protected)
        function setupImpl(~)
        end

        function stepImpl(~)
        end

        function num = getNumInputsImpl(~)
            num = 0;
        end

        function num = getNumOutputsImpl(~)
            num = 0;
        end

        function icon = getIconImpl(obj)
            extra = obj.ExtraBlocks;
            if isempty(extra)
                extra = "Not implemented";
            end
            maxLines = min(6, numel(extra));
            icon = [obj.BoardName; "Not implemented:"; extra(1:maxLines).'];
        end
    end
end
