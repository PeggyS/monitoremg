function rc_change_mep_val(source,event, app)

func = @(p,x) p(3)./(1+exp(p(1)*(p(2)-x)));
p = app.rc_fit_ui.eqn_params;

% mep_val
mep_val = str2double(app.rc_fit_ui.edMEPval.String);


x = fzero(@(z)(func(p,z)-mep_val), 50);

app.rc_fit_ui.editStimval.String = num2str(round(x, 2));

