classdef WifiTransmit < matlab.System & coder.ExternalDependency
    %WIFITRANSMIT - Send a uint8 payload over Wi-Fi UDP or TCP.
    %   The input port is uint8 and DataLength-by-1. Protocol is "UDP" or "TCP".
    %   ESP32 uses the core WiFi library and this class adds no lib_dep. MKR and
    %   Uno R4 subclasses add WiFiNINA or WiFiS3. Host simulation does not send.
    %
    %   Syntax:
    %       obj = arduinopio.blocks.common.WifiTransmit
    %       obj = arduinopio.blocks.common.WifiTransmit(Name=value)
    %
    %   Inputs:
    %       Protocol - "UDP" or "TCP". Default "UDP".
    %       Ssid, Password, RemoteHost - strings.
    %       RemotePort - (1,1) uint16 destination port. Default 5000.
    %       DataLength - (1,1) bytes, 1 to 64. Default 1.
    %       SampleTime - (1,1) double. Default -1.
    %       u (step) - uint8 column of length DataLength.
    %
    %   Outputs:
    %       obj - WifiTransmit System object.
    %
    %   Example:
    %       obj = arduinopio.blocks.common.WifiTransmit(Protocol="TCP", RemotePort=uint16(80));
    %
    %   Other m-files required: arduinopio.cString, arduinopio.updateDriverBuildInfo
    %   Subfunctions: none
    %   MAT-files required: none
    %
    %   See also: WIFIRECEIVE, CSTRING

    %   Author: Frey, Jed
    %   07-Oct-2026; Last revision: 07-Oct-2026

    properties (Nontunable)
        Protocol (1,:) char {mustBeMember(Protocol, {'UDP', 'TCP'})} = 'UDP'
        Ssid (1,:) char = 'arduino'
        Password (1,:) char = 'password'
        RemoteHost (1,:) char = '192.168.1.20'
        RemotePort (1,1) uint16 = 5000
        DataLength (1,1) {mustBeInteger, mustBeInRange(DataLength, 1, 64)} = 1
        SampleTime (1,1) double = -1
    end

    methods
        function obj = WifiTransmit(varargin)
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

        function stepImpl(obj, u)
            if coder.target("Rtw")
                data = uint8(u(:));
                host = arduinopio.cString(obj.RemoteHost, 64);
                coder.cinclude("arduinopio_wifi.h");
                if strcmp(obj.Protocol, 'TCP')
                    coder.ceval("arduinopioWifiTcpSend", coder.rref(host), obj.RemotePort, ...
                        coder.rref(data), uint8(numel(data)));
                else
                    coder.ceval("arduinopioWifiUdpSend", coder.rref(host), obj.RemotePort, ...
                        coder.rref(data), uint8(numel(data)));
                end
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
            icon = ['WiFi ', obj.Protocol, ' TX'];
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
            name = "Arduino PIO WiFi Transmit";
        end

        function tf = isSupportedContext(context)
            tf = context.isCodeGenTarget("rtw");
        end

        function updateBuildInfo(buildInfo, context)
            arduinopio.updateDriverBuildInfo(buildInfo, context, "arduinopio_wifi.cpp");
        end
    end
end
