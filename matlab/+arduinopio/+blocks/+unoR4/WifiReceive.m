classdef (Sealed) WifiReceive < arduinopio.blocks.common.WifiReceive
    %WIFIRECEIVE - Uno R4 WiFi receive. Adds the WiFiS3 library dependency.
    %
    %   Syntax:
    %       obj = arduinopio.blocks.unoR4.WifiReceive
    %
    %   Inputs:
    %       varargin - WifiReceive name-value pairs.
    %
    %   Outputs:
    %       obj - Uno R4 WifiReceive System object.
    %
    %   Example:
    %       obj = arduinopio.blocks.unoR4.WifiReceive(Protocol="TCP");
    %
    %   Other m-files required: arduinopio.addLibDep
    %   Subfunctions: none
    %   MAT-files required: none
    %
    %   See also: WIFITRANSMIT

    %   Author: Frey, Jed
    %   07-Oct-2026; Last revision: 07-Oct-2026

    methods
        function obj = WifiReceive(varargin)
            obj@arduinopio.blocks.common.WifiReceive(varargin{:});
        end
    end

    methods (Static)
        function updateBuildInfo(buildInfo, context)
            arduinopio.blocks.common.WifiReceive.updateBuildInfo(buildInfo, context);
            arduinopio.addLibDep(buildInfo, "WIFIS3");
        end
    end
end
