function command = maskDisplayWithPin(title, options)
%maskDisplayWithPin Simulink mask Display command that shows a pin number.
    arguments
        title (1,1) string
        options.Expression (1,1) string = "Pin"
        options.Label (1,1) string = "Pin"
    end

    command = "fprintf('" + title + "\\n" + options.Label + " %g', " + options.Expression + ")";
end
