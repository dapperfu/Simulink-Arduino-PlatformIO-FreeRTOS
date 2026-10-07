classdef BleTransmit < matlab.System & coder.ExternalDependency
    %BLETRANSMIT - Notify a uint8 payload on a BLE characteristic.
    %   The input port is uint8 and DataLength-by-1, at most 20 bytes. ESP32
    %   uses the core BLE stack. ArduinoBleTransmit adds the ArduinoBLE library
    %   for MKR and Nano 33 BLE. Host simulation does not transmit.
    %
    %   Syntax:
    %       obj = arduinopio.blocks.common.BleTransmit
    %       obj = arduinopio.blocks.common.BleTransmit(Name=value)
    %
    %   Inputs:
    %       DeviceName, ServiceUuid, CharacteristicUuid - strings.
    %       DataLength - (1,1) bytes, 1 to 20. Default 1.
    %       SampleTime - (1,1) double. Default -1.
    %       u (step) - uint8 column of length DataLength.
    %
    %   Outputs:
    %       obj - BleTransmit System object.
    %
    %   Example:
    %       obj = arduinopio.blocks.common.BleTransmit(DeviceName="sensor");
    %
    %   Other m-files required: arduinopio.cString, arduinopio.updateDriverBuildInfo
    %   Subfunctions: none
    %   MAT-files required: none
    %
    %   See also: BLERECEIVE, ARDUINOBLETRANSMIT

    %   Author: Frey, Jed
    %   07-Oct-2026; Last revision: 07-Oct-2026

    properties (Nontunable)
        DeviceName (1,:) char = 'ArduinoPIO'
        ServiceUuid (1,:) char = '19B10000-E8F2-537E-4F6C-D104768A1214'
        CharacteristicUuid (1,:) char = '19B10001-E8F2-537E-4F6C-D104768A1214'
        DataLength (1,1) {mustBeInteger, mustBeInRange(DataLength, 1, 20)} = 1
        SampleTime (1,1) double = -1
    end

    methods
        function obj = BleTransmit(varargin)
            coder.allowpcode("plain");
            setProperties(obj, nargin, varargin{:});
        end
    end

    methods (Access = protected)
        function setupImpl(obj)
            if coder.target("Rtw")
                deviceName = arduinopio.cString(obj.DeviceName, 32);
                serviceUuid = arduinopio.cString(obj.ServiceUuid, 38);
                characteristicUuid = arduinopio.cString(obj.CharacteristicUuid, 38);
                coder.cinclude("arduinopio_ble.h");
                coder.ceval("arduinopioBleSetup", coder.rref(deviceName), ...
                    coder.rref(serviceUuid), coder.rref(characteristicUuid));
            end
        end

        function stepImpl(obj, u)
            if coder.target("Rtw")
                data = uint8(u(:));
                coder.cinclude("arduinopio_ble.h");
                coder.ceval("arduinopioBleWrite", coder.rref(data), uint8(numel(data)));
            end
        end

        function num = getNumInputsImpl(~)
            num = 1;
        end

        function num = getNumOutputsImpl(~)
            num = 0;
        end

        function name = getInputNamesImpl(~)
            name = "Data";
        end

        function sz = getInputSizeImpl(obj)
            sz = [obj.DataLength, 1];
        end

        function dt = getInputDataTypeImpl(~)
            dt = "uint8";
        end

        function flag = isInputComplexImpl(~, ~)
            flag = false;
        end

        function flag = isInputFixedSizeImpl(~, ~)
            flag = true;
        end

        function icon = getIconImpl(obj)
            icon = ['BLE TX ', obj.DeviceName];
        end

        function sts = getSampleTimeImpl(obj)
            if obj.SampleTime == -1
                sts = createSampleTime(obj, Type="Inherited");
            else
                sts = createSampleTime(obj, Type="Discrete", SampleTime=obj.SampleTime);
            end
        end
    end

    methods (Static)
        function name = getDescriptiveName(~)
            name = "Arduino PIO BLE Transmit";
        end

        function tf = isSupportedContext(context)
            tf = context.isCodeGenTarget("rtw");
        end

        function updateBuildInfo(buildInfo, context)
            arduinopio.updateDriverBuildInfo(buildInfo, context, "arduinopio_ble.cpp");
        end
    end
end
