classdef (Sealed) I2cWrite < matlab.System & coder.ExternalDependency
    %I2CWRITE - Write bytes to an I2C slave device over Arduino Wire.
    %   Sealed matlab.System plus coder.ExternalDependency. Uno uses SDA on A4
    %   and SCL on A5. Nontunable SlaveAddress defaults to 8, HasRegister to
    %   true, RegisterAddress to 0, SampleTime to -1 (inherited). On RTW,
    %   setupImpl includes arduinopio_i2c.h and calls arduinopioI2cSetup.
    %   stepImpl casts the input to a uint8 column and calls arduinopioI2cWrite
    %   with slave address, HasRegister, register address, coder.rref(data), and
    %   numel(data). Host simulation performs no write. updateBuildInfo adds
    %   arduinopio_i2c.cpp. This System object is the block implementation.
    %
    %   Syntax:
    %       obj = arduinopio.blocks.common.I2cWrite
    %       obj = arduinopio.blocks.common.I2cWrite(Name=value)
    %
    %   Inputs:
    %       SlaveAddress    - (1,1) nonnegative integer I2C address. Default: 8.
    %       HasRegister     - (1,1) logical; write register before data. Default: true.
    %       RegisterAddress - (1,1) nonnegative integer register. Default: 0.
    %       SampleTime      - (1,1) double. Default: -1 (inherited).
    %       u (step)        - Bytes to write; cast to uint8 column in stepImpl.
    %
    %   Outputs:
    %       obj - I2cWrite System object. stepImpl has one input and no outputs.
    %
    %   Example:
    %       obj = arduinopio.blocks.common.I2cWrite(SlaveAddress=0x48);
    %
    %   Other m-files required: arduinopio.updateDriverBuildInfo
    %   Subfunctions: none
    %   MAT-files required: none
    %
    %   See also: I2CREAD, SPIWRITEREAD

    %   Author: Frey, Jed
    %   28-Sep-2026; Last revision: 28-Sep-2026

    properties (Nontunable)
        SlaveAddress (1,1) {mustBeInteger, mustBeNonnegative} = 8
        HasRegister (1,1) logical = true
        RegisterAddress (1,1) {mustBeInteger, mustBeNonnegative} = 0
        SampleTime (1,1) double = -1
    end

    methods
        function obj = I2cWrite(varargin)
        %I2CWRITE - Construct an I2cWrite System object from name-value pairs.
        %   Calls coder.allowpcode("plain") and setProperties for nontunable
        %   slave, register, and sample-time properties.
        %
        %   Syntax:
        %       obj = I2cWrite()
        %       obj = I2cWrite(Name=value)
        %
        %   Inputs:
        %       varargin - Optional name-value pairs for nontunable properties.
        %
        %   Outputs:
        %       obj - Constructed I2cWrite instance.
        %
        %   Example:
        %       obj = arduinopio.blocks.common.I2cWrite(HasRegister=false);
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

        function stepImpl(obj, u)
        %STEPIMPL - Write input bytes to the I2C slave on RTW.
        %   Casts u(:) to uint8 and calls arduinopioI2cWrite with SlaveAddress,
        %   HasRegister, RegisterAddress, coder.rref(data), and numel(data).
        %   Host simulation performs no hardware write.
        %
        %   Syntax:
        %       stepImpl(obj, u)
        %
        %   Inputs:
        %       obj - I2cWrite System object.
        %       u   - Bytes to transmit; reshaped to a uint8 column.
        %
        %   Outputs:
        %       none
        %
        %   Example:
        %       % Driven each sample by the Simulink System block.
        %
        %   See also: SETUPIMPL, ARDUINOPIOI2CWRITE

            if coder.target("Rtw")
                data = uint8(u(:));
                coder.ceval("arduinopioI2cWrite", uint8(obj.SlaveAddress), uint8(obj.HasRegister), ...
                    uint8(obj.RegisterAddress), coder.rref(data), uint8(numel(data)));
            end
        end

        function num = getNumInputsImpl(~)
        %GETNUMINPUTSIMPL - Report one input port for write data.
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
        %GETNUMOUTPUTSIMPL - Report zero output ports for I2C write.
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
        %GETICONIMPL - Block icon label for I2C Write.
        %   Returns the string "I2C Write".
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

            icon = "I2C Write";
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
        %       obj - I2cWrite System object.
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
        %GETDESCRIPTIVENAME - Return the codegen display name for I2C Write.
        %   Returns the string "Arduino PIO I2C Write".
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

            name = "Arduino PIO I2C Write";
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
