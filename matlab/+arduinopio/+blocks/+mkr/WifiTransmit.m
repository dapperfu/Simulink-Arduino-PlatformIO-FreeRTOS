classdef (Sealed) WifiTransmit < arduinopio.blocks.common.WifiTransmit
    %WIFITRANSMIT - MKR WiFi transmit. Adds the WiFiNINA library dependency.
    %
    %   Syntax:
    %       obj = arduinopio.blocks.mkr.WifiTransmit
    %
    %   Inputs:
    %       varargin - WifiTransmit name-value pairs.
    %
    %   Outputs:
    %       obj - MKR WifiTransmit System object.
    %
    %   Example:
    %       obj = arduinopio.blocks.mkr.WifiTransmit(Protocol="UDP");
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
            arduinopio.addLibDep(buildInfo, "WIFININA");
        end
    end
end
