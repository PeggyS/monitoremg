function rc_change_norm_factor(source,event, app)

% norm factor
norm_factor = str2double(app.rc_fit_ui.edNormFactor.String);

h_ax = app.rc_axes;
% cla(h_ax)

% find out if app is displaying MEP ampl or auc
tag = 'rb_mep_ampl'; % default is p2p amplitude
if isprop(app, 'h_radio_mep')
	for kk = 1:length(app.h_radio_mep.Children)
		if app.h_radio_mep.Children(kk).Value
			tag = app.h_radio_mep.Children(kk).Tag; % tag of selected radio button (either rb_mep_ampl, or rb_mep_auc)
		end
	end
end
switch tag
	case 'rb_mep_ampl'
		if norm_factor == 1
			h_ax.YLabel.String = 'MEP Vp-p (µV)';
		else
			h_ax.YLabel.String = 'Normalized EMG Amplitude';
		end
		data_var = 'MEPAmpl_uVPp';
	case 'rb_mep_auc'
		if norm_factor == 1
			h_ax.YLabel.String = 'MEP AUC (µV*ms)';
		else
			h_ax.YLabel.String = 'Normalized EMG AUC';
		end
		data_var = 'MEPAUC_uV_ms';
end

% if norm_factor == 1
% 	h_ax.YLabel.String = 'EMG (µV)';
% else
% 	h_ax.YLabel.String = 'Normalized EMG';
% end

data = app.rc_axes.UserData;

% for cnt = 1:height(data)
% 	if data.Use(cnt)
% 		add_point2rc(h_ax, data.Epoch(cnt), data.MagStim_Setting(cnt), data.(data_var)(cnt)/norm_factor)
% 	end
% end


% change the data points
for row_cnt = 1:height(app.rc_axes.UserData)
	h_line = find_rc_datapoint(app.rc_axes, row_cnt);
	h_line.YData = app.rc_axes.UserData.(data_var)(row_cnt)/norm_factor;
end

% scale m-min & m-max by the norm_factor
app.rc_fit_ui.edMEPmax.String = num2str(str2double(app.rc_fit_ui.edMEPmax.String) / norm_factor);
app.rc_fit_ui.edMEPmin.String = num2str(str2double(app.rc_fit_ui.edMEPmin.String) / norm_factor);

% remove curve fit lines
h_ci_lines = findobj(app.rc_axes, 'Tag', 'ci_line');
if ~isempty(h_ci_lines)
	delete(h_ci_lines)
end
h_err = findobj(app.rc_axes, 'Tag', 'errLine');
if ~isempty(h_err)
	delete(h_err)
end
h_ml = findobj(app.rc_axes, 'Tag', 'meanLine');
if ~isempty(h_ml)
	delete(h_ml)
end