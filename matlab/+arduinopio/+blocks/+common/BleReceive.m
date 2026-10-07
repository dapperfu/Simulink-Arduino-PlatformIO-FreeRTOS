classdef BleReceive < matlab.System & coder.ExternalDependency
    %BLERECEIVE - Read a uint8 payload written to a BLE characteristic.
    %   Outputs are uint8 data of length DataLength and a logical status.
    %   Status is true when a central wrote the characteristic. Host simulation
    %   returns zeros and false.
    %
    %   Syntax:
    %       obj = arduinopio.blocks.common.BleReceive
    %       obj = arduinopio.blocks.common.BleReceive(Name=value)
    %
    %   Inputs:
    %       DeviceName, ServiceUuid, CharacteristicUuid - strings.
    %       DataLength - (1,1) bytes, 1 to 20. Default 1.
    %       SampleTime - (1,1) double. Default -1.
    %
    %   Outputs:
    %       data - uint8 column of length DataLength.
    %       status - logical scalar.
    %
    %   Example:
    %       obj = arduinopio.blocks.common.BleReceive(DeviceName="sensor");
    %
    %   Other m-files required: arduinopio.cString, arduinopio.updateDriverBuildInfo
    %   Subfunctions: none
    %   MAT-files required: none
    %
    %   See also: BLETRANSMIT, ARDUINOBLERECEIVE

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
        function obj = BleReceive(varargin)
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

        function [data, status] = stepImpl(obj)
            data = zeros(obj.DataLength, 1, "uint8");
            status = false;
            if coder.target("Rtw")
                count = uint8(0);
                coder.cinclude("arduinopio_ble.h");
                count = coder.ceval("arduinopioBleRead", coder.wref(data), uint8(obj.DataLength));
                status = count > 0;
            end
        end

        function num = getNumInputsImpl(~)
            num = 0;
        end

        function num = getNumOutputsImpl(~)
            num = 2;
        end

        function names = getOutputNamesImpl(~)
            names = ["Data", "Status"];
        end

        function [sz1, sz2] = getOutputSizeImpl(obj)
            sz1 = [obj.DataLength, 1];
            sz2 = [1, 1];
        end

        function [dt1, dt2] = getOutputDataTypeImpl(~)
            dt1 = "uint8";
            dt2 = "logical";
        end

        function [c1, c2] = isOutputComplexImpl(~)
            c1 = false;
            c2 = false;
        end

        function [f1, f2] = isOutputFixedSizeImpl(~)
            f1 = true;
            f2 = true;
        end

        function icon = getIconImpl(obj)
            icon = ['BLE RX ', obj.DeviceName];
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
            name = "Arduino PIO BLE Receive";
        end

        function tf = isSupportedContext(context)
            tf = context.isCodeGenTarget("rtw");
        end

        function updateBuildInfo(buildInfo, context)
            arduinopio.updateDriverBuildInfo(buildInfo, context, "arduinopio_ble.cpp");
        end
    end
end
