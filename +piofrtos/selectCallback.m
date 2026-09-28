function selectCallback(hDlg, hSrc)
%selectCallback Configure a model when piofrtos.tlc is selected.
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
