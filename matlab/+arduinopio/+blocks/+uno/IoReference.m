classdef (Sealed) IoReference < matlab.System
    %IoReference Uno R3 pin map reference. Classic Uno has no unique native I/O blocks.

    methods
        function obj = IoReference(varargin)
            coder.allowpcode("plain");
            setProperties(obj, nargin, varargin{:});
        end
    end

    methods (Access = protected)
        function setupImpl(~)
        end

        function stepImpl(~)
        end

        function num = getNumInputsImpl(~)
            num = 0;
        end

        function num = getNumOutputsImpl(~)
            num = 0;
        end

        function icon = getIconImpl(~)
            icon = [ ...
                "Uno R3 I/O"
                "D0-D13 GPIO"
                "A0-A5 ADC"
                "PWM 3,5,6,9,10,11"
                "INT 2,3  UART 0/1"
                "I2C A4/A5  SPI 10-13"
                "EEPROM 1 KB"
                "MCP2515 CAN on SPI"
                "No DAC/BLE/WiFi/native CAN"];
        end
    end

    methods (Static, Access = protected)
        function header = getHeaderImpl()
            header = matlab.system.display.Header( ...
                "arduinopio.blocks.uno.IoReference", ...
                Title="Uno I/O Reference", ...
                Text="Use Common and Advanced AVR blocks. CAN is MCP2515 over SPI, not a native CAN controller.");
        end
    end
end
