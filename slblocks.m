function blkStruct = slblocks
%SLBLOCKS - Register arduinopio_lib in the Simulink Library Browser.
%   Returns a blkStruct with Browser.Library set to "arduinopio_lib",
%   Browser.Name "Arduino PIO FreeRTOS", and Browser.IsFlat 0 so the library
%   appears as a hierarchical entry after createArduinoPioLibrary has saved
%   libraries/arduinopio_lib.slx and the path includes that folder.
%
%   Syntax:
%       blkStruct = slblocks
%
%   Inputs:
%       none
%
%   Outputs:
%       blkStruct - Struct with Browser field for Library Browser registration
%
%   Example:
%       blkStruct = slblocks;
%
%   Other m-files required: none
%   Subfunctions: none
%   MAT-files required: none
%
%   See also: CREATEARDUINOPIOLIBRARY, SL_CUSTOMIZATION, SETUPARDUINOPIOPATH

%   Author: Frey, Jed
%   28-Sep-2026; Last revision: 28-Sep-2026

%------------- BEGIN CODE --------------

    Browser.Library = "arduinopio_lib";
    Browser.Name = "Arduino PIO FreeRTOS";
    Browser.IsFlat = 0;
    blkStruct.Browser = Browser;
end
