classdef (Sealed) I2cRead < matlab.System & coder.ExternalDependency
    %I2CREAD - Read bytes from an I2C slave device over Arduino Wire.
    %   Sealed matlab.System plus coder.ExternalDependency. Uno uses SDA on A4
    %   and SCL on A5. Nontunable SlaveAddress defaults to 8, HasRegister to
    %   true, RegisterAddress to 0, DataLength to 1, SampleTime to -1
    %   (inherited). On RTW, setupImpl includes arduinopio_i2c.h and calls
    %   arduinopioI2cSetup. stepImpl returns a DataLength-by-1 uint8 column;
    %   on RTW it calls arduinopioI2cRead with slave address, HasRegister flag,
    %   register address, write-ref buffer, and length. Host simulation returns
    %   zeros. updateBuildInfo adds arduinopio_i2c.cpp. This System object is
    %   the block implementation.
    %
    %   Syntax:
    %       obj = arduinopio.blocks.common.I2cRead
    %       obj = arduinopio.blocks.common.I2cRead(Name=value)
    %
    %   Inputs:
    %       SlaveAddress    - (1,1) nonnegative integer I2C address. Default: 8.
    %       HasRegister     - (1,1) logical; write register before read. Default: true.
    %       RegisterAddress - (1,1) nonnegative integer register. Default: 0.
    %       DataLength      - (1,1) positive integer bytes to read. Default: 1.
    %       SampleTime      - (1,1) double. Default: -1 (inherited).
    %
    %   Outputs:
    %       obj  - I2cRead System object.
    %       data - stepImpl output: DataLength-by-1 uint8 column of read bytes.
    %
    %   Example:
    %       obj = arduinopio.blocks.common.I2cRead(SlaveAddress=0x48, DataLength=2);
    %
    %   Other m-files required: arduinopio.updateDriverBuildInfo
    %   Subfunctions: none
    %   MAT-files required: none
    %
    %   See also: I2CWRITE, SPIWRITEREAD

    %   Author: Frey, Jed
    %   28-Sep-2026; Last revision: 28-Sep-2026

    properties (Nontunable)
        SlaveAddress (1,1) {mustBeInteger, mustBeNonnegative} = 8
        HasRegister (1,1) logical = true
        RegisterAddress (1,1) {mustBeInteger, mustBeNonnegative} = 0
        DataLength (1,1) {mustBeInteger, mustBePositive} = 1
        SampleTime (1,1) double = -1
    end

    methods
        function obj = I2cRead(varargin)
        %I2CREAD - Construct an I2cRead System object from name-value pairs.
        %   Calls coder.allowpcode("plain") and setProperties for nontunable
        %   slave, register, length, and sample-time properties.
        %
        %   Syntax:
        %       obj = I2cRead()
        %       obj = I2cRead(Name=value)
        %
        %   Inputs:
        %       varargin - Optional name-value pairs for nontunable properties.
        %
        %   Outputs:
        %       obj - Constructed I2cRead instance.
        %
        %   Example:
        %       obj = arduinopio.blocks.common.I2cRead(DataLength=4);
        %
        %   See also: SETUPIMPL, STEPIMPL

            coder.allowpcode("plain");
            setProperties(obj, nargin, varargin{:});
        end
    end

    methods (Access = protected)
        function setupImpl(~)
        %SETUPIMPL - Initialize the I2C driver on RTW targets.
        %   When coder.target is "Rtw", includes arduinopio_i2c.h and calls
        %   arduinopioI2cSetup. Host simulation performs no setup.
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
        %       % Invoked once before stepImpl during simulation or codegen.
        %
        %   See also: STEPIMPL, ARDUINOPIOI2CSETUP

            if coder.target("Rtw")
                coder.cinclude("arduinopio_i2c.h");
                coder.ceval("arduinopioI2cSetup");
            end
        end

        function data = stepImpl(obj)
        %STEPIMPL - Read DataLength bytes from the I2C slave.
        %   Preallocates zeros(DataLength,1,"uint8"). On RTW calls
        %   arduinopioI2cRead with SlaveAddress, HasRegister, RegisterAddress,
        %   coder.wref(data), and DataLength. Host returns the zero buffer.
        %
        %   Syntax:
        %       data = stepImpl(obj)
        %
        %   Inputs:
        %       obj - I2cRead System object.
        %
        %   Outputs:
        %       data - DataLength-by-1 uint8 column of bytes read (zeros on host).
        %
        %   Example:
        %       % Driven each sample by the Simulink System block.
        %
        %   See also: SETUPIMPL, ARDUINOPIOI2CREAD

            data = zeros(obj.DataLength, 1, "uint8");
            if coder.target("Rtw")
                coder.ceval("arduinopioI2cRead", uint8(obj.SlaveAddress), uint8(obj.HasRegister), ...
                    uint8(obj.RegisterAddress), coder.wref(data), uint8(obj.DataLength));
            end
        end

        function num = getNumInputsImpl(~)
        %GETNUMINPUTSIMPL - Report zero input ports for I2C read.
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
        %GETNUMOUTPUTSIMPL - Report one output port for read data.
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
        %GETOUTPUTSIZEIMPL - Output size DataLength-by-1 for read bytes.
        %   Returns [obj.DataLength, 1].
        %
        %   Syntax:
        %       sz = getOutputSizeImpl(obj)
        %
        %   Inputs:
        %       obj - I2cRead System object.
        %
        %   Outputs:
        %       sz - Size vector [DataLength, 1].
        %
        %   Example:
        %       % Queried during model compilation.
        %
        %   See also: GETOUTPUTDATATYPEIMPL

            sz = [obj.DataLength, 1];
        end

        function dt = getOutputDataTypeImpl(~)
        %GETOUTPUTDATATYPEIMPL - Output data type is uint8.
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
        %ISOUTPUTCOMPLEXIMPL - Read data output is real-valued.
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

        function f = isOutputFixedSizeImpl(~)
        %ISOUTPUTFIXEDSIZEIMPL - Read data output has fixed size.
        %   Always returns true.
        %
        %   Syntax:
        %       f = isOutputFixedSizeImpl(obj)
        %
        %   Inputs:
        %       ~ - Unused System object.
        %
        %   Outputs:
        %       f - true (fixed size).
        %
        %   Example:
        %       % Queried during model compilation.
        %
        %   See also: ISOUTPUTCOMPLEXIMPL

            f = true;
        end

        function icon = getIconImpl(~)
        %GETICONIMPL - Block icon label for I2C Read.
        %   Returns the string "I2C Read".
        %
        %   Syntax:
        %       icon = getIconImpl(obj)
        %
        %   Inputs:
        %       ~ - Unused System object.
        %
        %   Outputs:
        %       icon - Icon text for the Simulink block mask.
        %
        %   Example:
        %       % Queried when drawing the System block icon.
        %
        %   See also: STEPIMPL

            icon = "I2C Read";
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
        %       obj - I2cRead System object.
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
        %GETDESCRIPTIVENAME - Return the codegen display name for I2C Read.
        %   Returns the string "Arduino PIO I2C Read".
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

            name = "Arduino PIO I2C Read";
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
        %UPDATEBUILDINFO - Register arduinopio_i2c.cpp for codegen.
        %   Calls arduinopio.updateDriverBuildInfo with source
        %   "arduinopio_i2c.cpp".
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

            arduinopio.updateDriverBuildInfo(buildInfo, context, "arduinopio_i2c.cpp");
        end
    end
end
