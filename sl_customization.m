function sl_customization(~)
%SL_CUSTOMIZATION - Simulink customization entry for Arduino PIO FreeRTOS.
%   Called by Simulink when customizations refresh. This implementation takes
%   an unused customization manager argument and performs no registration here.
%   Library Browser registration lives in slblocks.m (arduinopio_lib). The code
%   generation target is piofrtos.tlc under the piofrtos folder.
%
%   Syntax:
%       sl_customization(cm)
%
%   Inputs:
%       cm - Unused Simulink customization manager handle
%
%   Outputs:
%       none
%
%   Example:
%       sl_refresh_customizations();
%
%   Other m-files required: none
%   Subfunctions: none
%   MAT-files required: none
%
%   See also: SLBLOCKS, SETUP_PIOFRTOS, INSTALLARDUINOPIO

%   Author: Frey, Jed
%   28-Sep-2026; Last revision: 28-Sep-2026

%------------- BEGIN CODE --------------

end
