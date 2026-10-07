classdef (Sealed) WifiTransmit < arduinopio.blocks.common.WifiTransmit
    %WIFITRANSMIT - Uno R4 WiFi transmit. Adds the WiFiS3 library dependency.
    %
    %   Syntax:
    %       obj = arduinopio.blocks.unoR4.WifiTransmit
    %
    %   Inputs:
    %       varargin - WifiTransmit name-value pairs.
    %
    %   Outputs:
    %       obj - Uno R4 WifiTransmit System object.
    %
    %   Example:
    %       obj = arduinopio.blocks.unoR4.WifiTransmit(Protocol="UDP");
    %
    %   Other m-files required: arduinopio.addLibDep
    %   Subfunctions: none
    %   MAT-files required: none
    %
    %   See also: WIFIRECEIVE

    %   Author: Frey, Jed
    %   07-Oct-2026; Last revision: 07-Oct-2026

    methods
        function obj = WifiTransmit(varargin)
            obj@arduinopio.blocks.common.WifiTransmit(varargin{:});
        end
    end

    methods (Static)
        function updateBuildInfo(buildInfo, context)
            arduinopio.blocks.common.WifiTransmit.updateBuildInfo(buildInfo, context);
            arduinopio.addLibDep(buildInfo, "WIFIS3");
        end
    end
end
