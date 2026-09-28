function selectCallback(hDlg, hSrc)
%SELECTCALLBACK - Configure a model when piofrtos.tlc is selected.
%   System target SelectCallback for the Arduino FreeRTOS (PlatformIO) STF.
%   Forces fixed-step multitasking settings suitable for FreeRTOS tasks:
%   SolverType Fixed-step, EnableMultiTasking on, ConcurrentTasks off,
%   SupportContinuousTime off, MatFileLogging off, PortableWordSizes on,
%   CombineOutputUpdateFcns on, TargetLang C, GenerateMakefile on,
%   MakeCommand make_rtw, TemplateMakefile piofrtos.tmf. Also attempts
%   GenerateSampleERTMain off and TargetOS BareBoardExample (optional).
%   Refreshes the dialog when possible.
%
%   Syntax:
%       piofrtos.selectCallback(hDlg, hSrc)
%
%   Inputs:
%       hDlg - Configuration Parameters dialog handle for slConfigUI* APIs.
%       hSrc - Config set / UI source object; used as fallback for set_param.
%
%   Outputs:
%       none
%
%   Example:
%       % Wired from rtwgensettings.SelectCallback in generated piofrtos.tlc.
%       piofrtos.selectCallback(hDlg, hSrc);
%
%   Other m-files required: none
%   Subfunctions: setConfigValue
%   MAT-files required: none
%
%   See also: CONFIGUREMODEL, GENERATETARGETFILES, SYNCKNOWNTARGET

%   Author: Frey, Jed
%   28-Sep-2026; Last revision: 28-Sep-2026

%------------- BEGIN CODE --------------
    arguments
        hDlg
        hSrc
    end

    setConfigValue(hDlg, hSrc, "SolverType", "Fixed-step");
    setConfigValue(hDlg, hSrc, "EnableMultiTasking", "on");
    setConfigValue(hDlg, hSrc, "ConcurrentTasks", "off");
    setConfigValue(hDlg, hSrc, "SupportContinuousTime", "off");
    setConfigValue(hDlg, hSrc, "MatFileLogging", "off");
    setConfigValue(hDlg, hSrc, "PortableWordSizes", "on");
    setConfigValue(hDlg, hSrc, "CombineOutputUpdateFcns", "on");
    setConfigValue(hDlg, hSrc, "TargetLang", "C");
    setConfigValue(hDlg, hSrc, "GenerateMakefile", "on");
    setConfigValue(hDlg, hSrc, "MakeCommand", "make_rtw");
    setConfigValue(hDlg, hSrc, "TemplateMakefile", "piofrtos.tmf");
    setConfigValue(hDlg, hSrc, "GenerateSampleERTMain", "off", false);
    setConfigValue(hDlg, hSrc, "TargetOS", "BareBoardExample", false);

    try
        hSrc.getConfigSet.refreshDialog;
    catch
        % Dialog refresh is optional when the config set is used programmatically.
    end
end

function setConfigValue(hDlg, hSrc, parameterName, parameterValue, isEnabled)
%SETCONFIGVALUE - Set a config parameter and optionally enable or disable it.
%   Local helper for selectCallback. Uses slConfigUISetVal and
%   slConfigUISetEnabled when the dialog API works; otherwise hSrc.set_param.
%   isEnabled defaults to true; false is used for GenerateSampleERTMain and
%   TargetOS so they are written but grayed out when present.
%
%   Syntax:
%       setConfigValue(hDlg, hSrc, parameterName, parameterValue)
%       setConfigValue(hDlg, hSrc, parameterName, parameterValue, isEnabled)
%
%   Inputs:
%       hDlg - Configuration Parameters dialog handle.
%       hSrc - Config set / UI source object.
%       parameterName - (1,1) string parameter name.
%       parameterValue - (1,1) string value to assign.
%       isEnabled - (1,1) logical UI enable state. Default: true.
%
%   Outputs:
%       none
%
%   Example:
%       setConfigValue(hDlg, hSrc, "TemplateMakefile", "piofrtos.tmf");
%
%   See also: SELECTCALLBACK
    arguments
        hDlg
        hSrc
        parameterName (1,1) string
        parameterValue (1,1) string
        isEnabled (1,1) logical = true
    end

    try
        slConfigUISetVal(hDlg, hSrc, parameterName, parameterValue);
        slConfigUISetEnabled(hDlg, hSrc, parameterName, double(isEnabled));
    catch
        try
            hSrc.set_param(parameterName, parameterValue);
        catch
            % Parameter may be absent until the ERT config component is attached.
        end
    end
end
