classdef (Sealed) IoReference < matlab.System
    %IOREFERENCE - Uno R3 pin map reference for the Arduino PIO library.
    %   Sealed matlab.System (no coder.ExternalDependency). Classic Uno has no
    %   unique native I/O blocks beyond Common and Advanced AVR. setupImpl and
    %   stepImpl are empty no-ops with zero ports. getIconImpl returns a fixed
    %   multi-line string summarizing D0-D13 GPIO, A0-A5 ADC, PWM pins,
    %   interrupts, UART, I2C, SPI, EEPROM, MCP2515 CAN on SPI, and absence of
    %   DAC/BLE/WiFi/native CAN. getHeaderImpl directs users to Common and
    %   Advanced AVR blocks and notes CAN is MCP2515 over SPI.
    %
    %   Syntax:
    %       obj = arduinopio.blocks.uno.IoReference
    %       obj = arduinopio.blocks.uno.IoReference(Name=value)
    %
    %   Inputs:
    %       none (no nontunable properties; varargin accepted by the constructor)
    %
    %   Outputs:
    %       obj - IoReference System object with no step ports.
    %
    %   Example:
    %       obj = arduinopio.blocks.uno.IoReference;
    %
    %   Other m-files required: none
    %   Subfunctions: none
    %   MAT-files required: none
    %
    %   See also: BOARDSTUB, PWM, ANALOGINPUTAVR

    %   Author: Frey, Jed
    %   28-Sep-2026; Last revision: 28-Sep-2026

    methods
        function obj = IoReference(varargin)
        %IOREFERENCE - Construct an IoReference System object.
        %   Calls coder.allowpcode("plain") and setProperties. There are no
        %   nontunable properties on this class.
        %
        %   Syntax:
        %       obj = IoReference()
        %       obj = IoReference(Name=value)
        %
        %   Inputs:
        %       varargin - Optional name-value pairs (none defined).
        %
        %   Outputs:
        %       obj - Constructed IoReference instance.
        %
        %   Example:
        %       obj = arduinopio.blocks.uno.IoReference;
        %
        %   See also: GETICONIMPL, GETHEADERIMPL

            coder.allowpcode("plain");
            setProperties(obj, nargin, varargin{:});
        end
    end

    methods (Access = protected)
        function setupImpl(~)
        %SETUPIMPL - No-op setup for the Uno I/O reference block.
        %   Performs no initialization; the block is documentation-only.
        %
        %   Syntax:
        %       setupImpl(obj)
        %
        %   Inputs:
        %       ~ - Unused System object.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       % Invoked once before stepImpl during simulation.
        %
        %   See also: STEPIMPL
        end

        function stepImpl(~)
        %STEPIMPL - No-op step for the Uno I/O reference block.
        %   Performs no computation; the block has zero input and output ports.
        %
        %   Syntax:
        %       stepImpl(obj)
        %
        %   Inputs:
        %       ~ - Unused System object.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       % Driven each sample by the Simulink System block.
        %
        %   See also: SETUPIMPL
        end

        function num = getNumInputsImpl(~)
        %GETNUMINPUTSIMPL - Report zero input ports for the I/O reference.
        %   Returns a fixed input count of 0.
        %
        %   Syntax:
        %       num = getNumInputsImpl(obj)
        %
        %   Inputs:
        %       ~ - Unused System object.
        %
        %   Outputs:
        %       num - Number of inputs (0).
        %
        %   Example:
        %       % Queried by the System object framework.
        %
        %   See also: GETNUMOUTPUTSIMPL

            num = 0;
        end

        function num = getNumOutputsImpl(~)
        %GETNUMOUTPUTSIMPL - Report zero output ports for the I/O reference.
        %   Returns a fixed output count of 0.
        %
        %   Syntax:
        %       num = getNumOutputsImpl(obj)
        %
        %   Inputs:
        %       ~ - Unused System object.
        %
        %   Outputs:
        %       num - Number of outputs (0).
        %
        %   Example:
        %       % Queried by the System object framework.
        %
        %   See also: GETNUMINPUTSIMPL

            num = 0;
        end

        function icon = getIconImpl(~)
        %GETICONIMPL - Return the fixed Uno R3 pin-map icon lines.
        %   Returns a string column summarizing GPIO, ADC, PWM, INT, UART,
        %   I2C, SPI, EEPROM, MCP2515 CAN, and missing DAC/BLE/WiFi/native CAN.
        %
        %   Syntax:
        %       icon = getIconImpl(obj)
        %
        %   Inputs:
        %       ~ - Unused System object.
        %
        %   Outputs:
        %       icon - Fixed multi-line string for the Simulink block mask.
        %
        %   Example:
        %       % Queried when drawing the System block icon.
        %
        %   See also: GETHEADERIMPL

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
        %GETHEADERIMPL - System block dialog header for Uno I/O guidance.
        %   Returns matlab.system.display.Header for
        %   "arduinopio.blocks.uno.IoReference" titled "Uno I/O Reference"
        %   directing users to Common and Advanced AVR blocks and noting CAN
        %   is MCP2515 over SPI.
        %
        %   Syntax:
        %       header = getHeaderImpl()
        %
        %   Inputs:
        %       none
        %
        %   Outputs:
        %       header - matlab.system.display.Header for the block dialog.
        %
        %   Example:
        %       % Queried when opening the System block dialog.
        %
        %   See also: MATLAB.SYSTEM.DISPLAY.HEADER

            header = matlab.system.display.Header( ...
                "arduinopio.blocks.uno.IoReference", ...
                Title="Uno I/O Reference", ...
                Text="Use Common and Advanced AVR blocks. CAN is MCP2515 over SPI, not a native CAN controller.");
        end
    end
end
