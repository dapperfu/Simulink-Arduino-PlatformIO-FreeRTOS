classdef (Sealed) NativeCanTransmit < arduinopio.blocks.common.NativeCanTransmit
    %NATIVECANTRANSMIT - Uno R4 native CAN transmit. Adds Arduino_CAN.
    %
    %   Syntax:
    %       obj = arduinopio.blocks.unoR4.NativeCanTransmit
    %
    %   Inputs:
    %       varargin - NativeCanTransmit name-value pairs.
    %
    %   Outputs:
    %       obj - Uno R4 NativeCanTransmit System object.
    %
    %   Example:
    %       obj = arduinopio.blocks.unoR4.NativeCanTransmit(Board="unoR4");
    %
    %   Other m-files required: arduinopio.addLibDep
    %   Subfunctions: none
    %   MAT-files required: none
    %
    %   See also: NATIVECANRECEIVE

    %   Author: Frey, Jed
    %   07-Oct-2026; Last revision: 07-Oct-2026

    methods
        function obj = NativeCanTransmit(varargin)
            obj@arduinopio.blocks.common.NativeCanTransmit(varargin{:});
        end
    end

    methods (Static)
        function updateBuildInfo(buildInfo, context)
            arduinopio.blocks.common.NativeCanTransmit.updateBuildInfo(buildInfo, context);
            arduinopio.addLibDep(buildInfo, "ARDUINO_CAN");
        end
    end
end
