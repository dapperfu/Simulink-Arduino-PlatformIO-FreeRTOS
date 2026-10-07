classdef WifiReceive < matlab.System & coder.ExternalDependency
    %WIFIRECEIVE - Read a uint8 payload over Wi-Fi UDP or TCP.
    %   Outputs are uint8 data of length DataLength and a logical status.
    %   Status is true when the driver returns at least one byte. Host
    %   simulation returns zeros and false. ESP32 needs no extra library.
    %
    %   Syntax:
    %       obj = arduinopio.blocks.common.WifiReceive
    %       obj = arduinopio.blocks.common.WifiReceive(Name=value)
    %
    %   Inputs:
    %       Protocol - "UDP" or "TCP". Default "UDP".
    %       Ssid, Password, RemoteHost - strings. RemoteHost is used by TCP.
    %       RemotePort - (1,1) uint16. Default 5000. TCP destination port.
    %       LocalPort - (1,1) uint16. Default 5000. UDP listen port.
    %       DataLength - (1,1) bytes, 1 to 64. Default 1.
    %       SampleTime - (1,1) double. Default -1.
    %
    %   Outputs:
    %       data - uint8 column of length DataLength.
    %       status - logical scalar.
    %
    %   Example:
    %       obj = arduinopio.blocks.common.WifiReceive(Protocol="UDP", LocalPort=uint16(5000));
    %
    %   Other m-files required: arduinopio.cString, arduinopio.updateDriverBuildInfo
    %   Subfunctions: none
    %   MAT-files required: none
    %
    %   See also: WIFITRANSMIT, CSTRING

    %   Author: Frey, Jed
    %   07-Oct-2026; Last revision: 07-Oct-2026

    properties (Nontunable)
        Protocol (1,:) char {mustBeMember(Protocol, {'UDP', 'TCP'})} = 'UDP'
        Ssid (1,:) char = 'arduino'
        Password (1,:) char = 'password'
        RemoteHost (1,:) char = '192.168.1.20'
        RemotePort (1,1) uint16 = 5000
        LocalPort (1,1) uint16 = 5000
        DataLength (1,1) {mustBeInteger, mustBeInRange(DataLength, 1, 64)} = 1
        SampleTime (1,1) double = -1
    end

    methods
        function obj = WifiReceive(varargin)
            coder.allowpcode("plain");
            setProperties(obj, nargin, varargin{:});
        end
    end

    methods (Access = protected)
        function setupImpl(obj)
            if coder.target("Rtw")
                ssid = arduinopio.cString(obj.Ssid, 32);
                password = arduinopio.cString(obj.Password, 64);
                coder.cinclude("arduinopio_wifi.h");
                coder.ceval("arduinopioWifiSetup", coder.rref(ssid), coder.rref(password));
            end
        end

        function [data, status] = stepImpl(obj)
            data = zeros(obj.DataLength, 1, "uint8");
            status = false;
            if coder.target("Rtw")
                count = uint8(0);
                host = arduinopio.cString(obj.RemoteHost, 64);
                coder.cinclude("arduinopio_wifi.h");
                if strcmp(obj.Protocol, 'TCP')
                    count = coder.ceval("arduinopioWifiTcpReceive", coder.rref(host), obj.RemotePort, ...
                        coder.wref(data), uint8(obj.DataLength));
                else
                    count = coder.ceval("arduinopioWifiUdpReceive", obj.LocalPort, ...
                        coder.wref(data), uint8(obj.DataLength));
                end
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
            icon = ['WiFi ', obj.Protocol, ' RX'];
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
            name = "Arduino PIO WiFi Receive";
        end

        function tf = isSupportedContext(context)
            tf = context.isCodeGenTarget("rtw");
        end

        function updateBuildInfo(buildInfo, context)
            arduinopio.updateDriverBuildInfo(buildInfo, context, "arduinopio_wifi.cpp");
        end
    end
end
