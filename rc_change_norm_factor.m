function rc_change_norm_factor(source,event, app)

% norm factor
norm_factor = str2double(app.rc_fit_ui.edNormFactor.String);

% is rc or sici axes being used
h_fig = findobj('Tag', 'rc_fig');
if isempty(h_fig)
	h_fig = findobj('Tag', 'sici_icf_fig');
	if isempty(h_fig)
		error('Could not find Recruitment Curve or SICI & ICF figure')
	end
end
h_ax = findobj(h_fig.Children, 'Type', 'Axes');

% find out if app is displaying MEP ampl or auc
tag = find_selected_radio_button(app.h_radio_mep);
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

% data = app.rc_axes.UserData;

% for cnt = 1:height(data)
% 	if data.Use(cnt)
% 		add_point2rc(h_ax, data.Epoch(cnt), data.MagStim_Setting(cnt), data.(data_var)(cnt)/norm_factor)
% 	end
% end


% change the data points
for row_cnt = 1:height(h_ax.UserData)
	h_line = find_rc_datapoint(h_ax, row_cnt);
	h_line.YData = h_ax.UserData.(data_var)(row_cnt)/norm_factor;
end

switch h_fig.Tag
	case 'rc_fig'
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
		
	case 'sici_icf_fig'
		% recalc the mean & ci lines
		recalc_sici([], [], app)
end