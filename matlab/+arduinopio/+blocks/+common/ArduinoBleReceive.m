classdef (Sealed) ArduinoBleReceive < arduinopio.blocks.common.BleReceive
    %ARDUINOBLERECEIVE - BLE receive that links the ArduinoBLE library.
    %   Same ports and mask properties as BleReceive. updateBuildInfo also
    %   records ARDUINOPIO_NEED_ARDUINOBLE.
    %
    %   Syntax:
    %       obj = arduinopio.blocks.common.ArduinoBleReceive
    %       obj = arduinopio.blocks.common.ArduinoBleReceive(Name=value)
    %
    %   Inputs:
    %       varargin - BleReceive name-value pairs.
    %
    %   Outputs:
    %       obj - ArduinoBleReceive System object.
    %
    %   Example:
    %       obj = arduinopio.blocks.common.ArduinoBleReceive(DeviceName="mkr");
    %
    %   Other m-files required: arduinopio.addLibDep
    %   Subfunctions: none
    %   MAT-files required: none
    %
    %   See also: BLERECEIVE, ARDUINOBLETRANSMIT

    %   Author: Frey, Jed
    %   07-Oct-2026; Last revision: 07-Oct-2026

    methods
        function obj = ArduinoBleReceive(varargin)
            obj@arduinopio.blocks.common.BleReceive(varargin{:});
        end
    end

    methods (Static)
        function updateBuildInfo(buildInfo, context)
            arduinopio.blocks.common.BleReceive.updateBuildInfo(buildInfo, context);
            arduinopio.addLibDep(buildInfo, "ARDUINOBLE");
        end
    end
end
