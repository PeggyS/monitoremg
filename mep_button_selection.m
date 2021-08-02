function mep_button_selection(source,event, app)
% disp(['Previous: ' event.OldValue.String]);
% disp(['Current: ' event.NewValue.String]);
% disp('------------------');

% update display of rc or sici
if isgraphics(app.rc_axes)
	axes_str = 'rc_axes';
	% reset norm factor
	app.rc_fit_ui.edNormFactor.String = '1';
elseif isgraphics(app.sici_axes)
	axes_str = 'sici_axes';
	app.rc_fit_ui.edNormFactor.String = '1';
else
	return
end

% which is displayed Auc or ampl p-p
switch event.NewValue.String
	case 'Area Under the Curve'
		app.h_emg_auc_patch.Visible = 'on';
		tbl_var_str = 'MEPAUC_uV_ms';
		app.(axes_str).YLabel.String = 'MEP AUC (µV*ms)';
		app.MmaxtoRCButton.Text = 'M AUC to RC';
	case 'Amplitude'
		app.h_emg_auc_patch.Visible = 'off';
		tbl_var_str = 'MEPAmpl_uVPp';
		app.(axes_str).YLabel.String = 'MEP Vp-p (µV)';
		app.MmaxtoRCButton.Text = 'M-max to RC';
end


% replot the data
app.(axes_str).YLabel.String;
for row_cnt = 1:height(app.(axes_str).UserData)
	h_line = find_rc_datapoint(app.(axes_str), row_cnt);
	h_line.YData = app.(axes_str).UserData.(tbl_var_str)(row_cnt);
end

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

% for sici fig, recalc the mean, ci lines, etc
if strcmp(axes_str, 'sici_axes')
	recalc_sici([], [], app)
end