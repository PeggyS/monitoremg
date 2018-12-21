function rc_change_stim_val(source,event, app)

% the sigmoid function with 3 parameters to fit
% func = inline('p(3)./(1+exp(p(1)*(p(2)-x)))','p','x');
func = @(p,x) p(3)./(1+exp(p(1)*(p(2)-x)));

p = app.rc_fit_ui.eqn_params;

% stim val
stim_val = str2double(app.rc_fit_ui.editStimval.String);


y = func(p, stim_val);

app.rc_fit_ui.edMEPval.String = num2str(round(y,2));