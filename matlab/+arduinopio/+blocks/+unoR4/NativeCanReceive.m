classdef (Sealed) NativeCanReceive < arduinopio.blocks.common.NativeCanReceive
    %NATIVECANRECEIVE - Uno R4 native CAN receive. Adds Arduino_CAN.
    %
    %   Syntax:
    %       obj = arduinopio.blocks.unoR4.NativeCanReceive
    %
    %   Inputs:
    %       varargin - NativeCanReceive name-value pairs.
    %
    %   Outputs:
    %       obj - Uno R4 NativeCanReceive System object.
    %
    %   Example:
    %       obj = arduinopio.blocks.unoR4.NativeCanReceive(Board="unoR4");
    %
    %   Other m-files required: arduinopio.addLibDep
    %   Subfunctions: none
    %   MAT-files required: none
    %
    %   See also: NATIVECANTRANSMIT

    %   Author: Frey, Jed
    %   07-Oct-2026; Last revision: 07-Oct-2026

    methods
        function obj = NativeCanReceive(varargin)
            obj@arduinopio.blocks.common.NativeCanReceive(varargin{:});
        end
    end

    methods (Static)
        function updateBuildInfo(buildInfo, context)
            arduinopio.blocks.common.NativeCanReceive.updateBuildInfo(buildInfo, context);
            arduinopio.addLibDep(buildInfo, "ARDUINO_CAN");
        end
    end
end
