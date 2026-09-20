function writeRtwScalar(block, name, value)
%writeRtwScalar Write a numeric dialog value into the generated model.rtw record.
    arguments
        block
        name (1,1) string
        value (1,1) {mustBeNumeric}
    end

    block.WriteRTWParam("string", name, sprintf("%.17g", double(value)));
end
