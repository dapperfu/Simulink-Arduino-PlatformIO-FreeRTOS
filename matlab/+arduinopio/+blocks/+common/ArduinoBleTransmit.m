classdef (Sealed) ArduinoBleTransmit < arduinopio.blocks.common.BleTransmit
    %ARDUINOBLETRANSMIT - BLE transmit that links the ArduinoBLE library.
    %   Same ports and mask properties as BleTransmit. updateBuildInfo also
    %   records ARDUINOPIO_NEED_ARDUINOBLE so MKR and Nano 33 BLE pull ArduinoBLE.
    %
    %   Syntax:
    %       obj = arduinopio.blocks.common.ArduinoBleTransmit
    %       obj = arduinopio.blocks.common.ArduinoBleTransmit(Name=value)
    %
    %   Inputs:
    %       varargin - BleTransmit name-value pairs.
    %
    %   Outputs:
    %       obj - ArduinoBleTransmit System object.
    %
    %   Example:
    %       obj = arduinopio.blocks.common.ArduinoBleTransmit(DeviceName="mkr");
    %
    %   Other m-files required: arduinopio.addLibDep
    %   Subfunctions: none
    %   MAT-files required: none
    %
    %   See also: BLETRANSMIT, ARDUINOBLERECEIVE

    %   Author: Frey, Jed
    %   07-Oct-2026; Last revision: 07-Oct-2026

    methods
        function obj = ArduinoBleTransmit(varargin)
            obj@arduinopio.blocks.common.BleTransmit(varargin{:});
        end
    end

    methods (Static)
        function updateBuildInfo(buildInfo, context)
            arduinopio.blocks.common.BleTransmit.updateBuildInfo(buildInfo, context);
            arduinopio.addLibDep(buildInfo, "ARDUINOBLE");
        end
    end
end
