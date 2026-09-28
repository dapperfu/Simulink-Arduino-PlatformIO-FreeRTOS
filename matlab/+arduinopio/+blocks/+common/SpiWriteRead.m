classdef (Sealed) SpiWriteRead < matlab.System & coder.ExternalDependency
    %SPIWRITEREAD - Full-duplex SPI transfer with chip-select control.
    %   Sealed matlab.System plus coder.ExternalDependency. Uno uses SS=10,
    %   MOSI=11, MISO=12, SCK=13. Nontunable ChipSelectPin defaults to 10,
    %   ClockHz to 4000000, SpiMode to 0 (member of 0-3), MsbFirst to true,
    %   SampleTime to -1 (inherited). validatePropertiesImpl validates the CS
    %   pin as kind "digital". On RTW, setupImpl includes arduinopio_spi.h and
    %   calls arduinopioSpiSetup(CS, ClockHz, SpiMode, MsbFirst). stepImpl casts
    %   the input to uint8; on host echoes tx as y, on RTW fills y via
    %   arduinopioSpiWriteRead. updateBuildInfo adds arduinopio_spi.cpp. This
    %   System object is the block implementation.
    %
    %   Syntax:
    %       obj = arduinopio.blocks.common.SpiWriteRead
    %       obj = arduinopio.blocks.common.SpiWriteRead(Name=value)
    %
    %   Inputs:
    %       ChipSelectPin - (1,1) nonnegative integer CS pin. Default: 10.
    %       ClockHz       - (1,1) positive integer SPI clock. Default: 4000000.
    %       SpiMode       - (1,1) integer in {0,1,2,3}. Default: 0.
    %       MsbFirst      - (1,1) logical bit order. Default: true.
    %       SampleTime    - (1,1) double. Default: -1 (inherited).
    %       u (step)      - Transmit bytes; cast to uint8 column in stepImpl.
    %
    %   Outputs:
    %       obj - SpiWriteRead System object.
    %       y   - stepImpl output: received bytes (host echoes transmit data).
    %
    %   Example:
    %       obj = arduinopio.blocks.common.SpiWriteRead(ChipSelectPin=10);
    %
    %   Other m-files required: arduinopio.validatePin, arduinopio.iconWithPin,
    %       arduinopio.updateDriverBuildInfo
    %   Subfunctions: none
    %   MAT-files required: none
    %
    %   See also: I2CREAD, I2CWRITE

    %   Author: Frey, Jed
    %   28-Sep-2026; Last revision: 28-Sep-2026

    properties (Nontunable)
        ChipSelectPin (1,1) {mustBeInteger, mustBeNonnegative} = 10
        ClockHz (1,1) {mustBeInteger, mustBePositive} = 4000000
        SpiMode (1,1) {mustBeInteger, mustBeMember(SpiMode, [0, 1, 2, 3])} = 0
        MsbFirst (1,1) logical = true
        SampleTime (1,1) double = -1
    end

    methods
        function obj = SpiWriteRead(varargin)
        %SPIWRITEREAD - Construct a SpiWriteRead System object.
        %   Calls coder.allowpcode("plain") and setProperties for nontunable
        %   CS pin, clock, mode, bit order, and sample time.
        %
        %   Syntax:
        %       obj = SpiWriteRead()
        %       obj = SpiWriteRead(Name=value)
        %
        %   Inputs:
        %       varargin - Optional name-value pairs for nontunable properties.
        %
        %   Outputs:
        %       obj - Constructed SpiWriteRead instance.
        %
        %   Example:
        %       obj = arduinopio.blocks.common.SpiWriteRead(SpiMode=0);
        %
        %   See also: SETUPIMPL, STEPIMPL

            coder.allowpcode("plain");
            setProperties(obj, nargin, varargin{:});
        end
    end

    methods (Access = protected)
        function validatePropertiesImpl(obj)
        %VALIDATEPROPERTIESIMPL - Validate the chip-select pin as digital.
        %   Calls arduinopio.validatePin(obj.ChipSelectPin, "digital").
        %
        %   Syntax:
        %       validatePropertiesImpl(obj)
        %
        %   Inputs:
        %       obj - SpiWriteRead System object.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       % Invoked by the System object framework during setup.
        %
        %   See also: VALIDATEPIN

            arduinopio.validatePin(obj.ChipSelectPin, "digital");
        end

        function setupImpl(obj)
        %SETUPIMPL - Configure SPI clock, mode, and chip select on RTW.
        %   When coder.target is "Rtw", includes arduinopio_spi.h and calls
        %   arduinopioSpiSetup(CS, ClockHz, SpiMode, MsbFirst). No host setup.
        %
        %   Syntax:
        %       setupImpl(obj)
        %
        %   Inputs:
        %       obj - SpiWriteRead System object.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       % Invoked once before stepImpl during simulation or codegen.
        %
        %   See also: STEPIMPL, ARDUINOPIOSPISETUP

            if coder.target("Rtw")
                coder.cinclude("arduinopio_spi.h");
                coder.ceval("arduinopioSpiSetup", uint8(obj.ChipSelectPin), uint32(obj.ClockHz), ...
                    uint8(obj.SpiMode), uint8(obj.MsbFirst));
            end
        end

        function y = stepImpl(obj, u)
        %STEPIMPL - Full-duplex SPI transfer of the transmit buffer.
        %   Builds uint8 tx from u(:). On host, y equals tx (echo). On RTW,
        %   preallocates zeros and calls arduinopioSpiWriteRead with CS,
        %   coder.rref(tx), coder.wref(y), and numel(tx).
        %
        %   Syntax:
        %       y = stepImpl(obj, u)
        %
        %   Inputs:
        %       obj - SpiWriteRead System object.
        %       u   - Transmit bytes; reshaped to a uint8 column.
        %
        %   Outputs:
        %       y - Received bytes (same size as tx; host echoes tx).
        %
        %   Example:
        %       % Driven each sample by the Simulink System block.
        %
        %   See also: SETUPIMPL, ARDUINOPIOSPIWRITEREAD

            tx = uint8(u(:));
            y = tx;
            if coder.target("Rtw")
                y = zeros(size(tx), "uint8");
                coder.ceval("arduinopioSpiWriteRead", uint8(obj.ChipSelectPin), coder.rref(tx), ...
                    coder.wref(y), uint8(numel(tx)));
            end
        end

        function num = getNumInputsImpl(~)
        %GETNUMINPUTSIMPL - Report one input port for SPI transmit data.
        %   Returns a fixed input count of 1.
        %
        %   Syntax:
        %       num = getNumInputsImpl(obj)
        %
        %   Inputs:
        %       ~ - Unused System object.
        %
        %   Outputs:
        %       num - Number of inputs (1).
        %
        %   Example:
        %       % Queried by the System object framework.
        %
        %   See also: GETNUMOUTPUTSIMPL

            num = 1;
        end

        function num = getNumOutputsImpl(~)
        %GETNUMOUTPUTSIMPL - Report one output port for SPI receive data.
        %   Returns a fixed output count of 1.
        %
        %   Syntax:
        %       num = getNumOutputsImpl(obj)
        %
        %   Inputs:
        %       ~ - Unused System object.
        %
        %   Outputs:
        %       num - Number of outputs (1).
        %
        %   Example:
        %       % Queried by the System object framework.
        %
        %   See also: GETNUMINPUTSIMPL

            num = 1;
        end

        function sz = getOutputSizeImpl(obj)
        %GETOUTPUTSIZEIMPL - Propagate receive size from the transmit input.
        %   Returns propagatedInputSize(obj, 1).
        %
        %   Syntax:
        %       sz = getOutputSizeImpl(obj)
        %
        %   Inputs:
        %       obj - SpiWriteRead System object.
        %
        %   Outputs:
        %       sz - Output size matching input 1.
        %
        %   Example:
        %       % Queried during model compilation.
        %
        %   See also: GETOUTPUTDATATYPEIMPL

            sz = propagatedInputSize(obj, 1);
        end

        function dt = getOutputDataTypeImpl(~)
        %GETOUTPUTDATATYPEIMPL - Receive data type is uint8.
        %   Returns the string "uint8".
        %
        %   Syntax:
        %       dt = getOutputDataTypeImpl(obj)
        %
        %   Inputs:
        %       ~ - Unused System object.
        %
        %   Outputs:
        %       dt - Data type name "uint8".
        %
        %   Example:
        %       % Queried during model compilation.
        %
        %   See also: GETOUTPUTSIZEIMPL

            dt = "uint8";
        end

        function c = isOutputComplexImpl(~)
        %ISOUTPUTCOMPLEXIMPL - SPI receive output is real-valued.
        %   Always returns false.
        %
        %   Syntax:
        %       c = isOutputComplexImpl(obj)
        %
        %   Inputs:
        %       ~ - Unused System object.
        %
        %   Outputs:
        %       c - false (not complex).
        %
        %   Example:
        %       % Queried during model compilation.
        %
        %   See also: ISOUTPUTFIXEDSIZEIMPL

            c = false;
        end

        function f = isOutputFixedSizeImpl(obj)
        %ISOUTPUTFIXEDSIZEIMPL - Propagate fixed-size flag from input 1.
        %   Returns propagatedInputFixedSize(obj, 1).
        %
        %   Syntax:
        %       f = isOutputFixedSizeImpl(obj)
        %
        %   Inputs:
        %       obj - SpiWriteRead System object.
        %
        %   Outputs:
        %       f - Fixed-size flag propagated from the transmit input.
        %
        %   Example:
        %       % Queried during model compilation.
        %
        %   See also: ISOUTPUTCOMPLEXIMPL

            f = propagatedInputFixedSize(obj, 1);
        end

        function icon = getIconImpl(obj)
        %GETICONIMPL - Build the block icon showing the chip-select pin.
        %   Returns arduinopio.iconWithPin("SPI WriteRead", ChipSelectPin,
        %   Label="CS").
        %
        %   Syntax:
        %       icon = getIconImpl(obj)
        %
        %   Inputs:
        %       obj - SpiWriteRead System object.
        %
        %   Outputs:
        %       icon - Icon line(s) for the Simulink block mask.
        %
        %   Example:
        %       % Queried when drawing the System block icon.
        %
        %   See also: ICONWITHPIN

            icon = arduinopio.iconWithPin("SPI WriteRead", obj.ChipSelectPin, Label="CS");
        end

        function sts = getSampleTimeImpl(obj)
        %GETSAMPLETIMEIMPL - Inherited or discrete sample time from SampleTime.
        %   If SampleTime is -1, creates Inherited sample time; otherwise
        %   Discrete with SampleTime equal to obj.SampleTime.
        %
        %   Syntax:
        %       sts = getSampleTimeImpl(obj)
        %
        %   Inputs:
        %       obj - SpiWriteRead System object.
        %
        %   Outputs:
        %       sts - Sample time specification from createSampleTime.
        %
        %   Example:
        %       % Queried during model compilation.
        %
        %   See also: CREATESAMPLETIME

            if obj.SampleTime == -1
                sts = createSampleTime(obj, Type="Inherited");
            else
                sts = createSampleTime(obj, Type="Discrete", SampleTime=obj.SampleTime);
            end
        end
    end

    methods (Static)
        function name = getDescriptiveName(~)
        %GETDESCRIPTIVENAME - Return the codegen display name for SPI WriteRead.
        %   Returns the string "Arduino PIO SPI WriteRead".
        %
        %   Syntax:
        %       name = getDescriptiveName(codeInfo)
        %
        %   Inputs:
        %       ~ - Unused code information argument.
        %
        %   Outputs:
        %       name - Descriptive name string.
        %
        %   Example:
        %       % Called by coder.ExternalDependency during build.
        %
        %   See also: ISSUPPORTEDCONTEXT, UPDATEBUILDINFO

            name = "Arduino PIO SPI WriteRead";
        end

        function tf = isSupportedContext(context)
        %ISSUPPORTEDCONTEXT - True when the build context targets RTW.
        %   Returns context.isCodeGenTarget("rtw").
        %
        %   Syntax:
        %       tf = isSupportedContext(context)
        %
        %   Inputs:
        %       context - Code generation context object.
        %
        %   Outputs:
        %       tf - Logical true for RTW codegen targets.
        %
        %   Example:
        %       % Called by coder.ExternalDependency during build.
        %
        %   See also: GETDESCRIPTIVENAME, UPDATEBUILDINFO

            tf = context.isCodeGenTarget("rtw");
        end

        function updateBuildInfo(buildInfo, context)
        %UPDATEBUILDINFO - Register arduinopio_spi.cpp for codegen.
        %   Calls arduinopio.updateDriverBuildInfo with source
        %   "arduinopio_spi.cpp".
        %
        %   Syntax:
        %       updateBuildInfo(buildInfo, context)
        %
        %   Inputs:
        %       buildInfo - RTW.BuildInfo object to update.
        %       context   - Code generation context object.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       % Called by coder.ExternalDependency during build.
        %
        %   See also: UPDATEDRIVERBUILDINFO

            arduinopio.updateDriverBuildInfo(buildInfo, context, "arduinopio_spi.cpp");
        end
    end
end
