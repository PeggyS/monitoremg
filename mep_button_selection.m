function mep_button_selection(source,event, app)
% disp(['Previous: ' event.OldValue.String]);
% disp(['Current: ' event.NewValue.String]);
% disp('------------------');

% update display of rc or sici
if isgraphics(app.rc_axes)
	axes_str = 'rc_axes';
elseif isgraphics(app.sici_axes)
	axes_str = 'sici_axes';
end

% which is displayed Auc or ampl p-p
switch event.NewValue.String
	case 'Area Under the Curve'
		app.h_emg_auc_patch.Visible = 'on';
		tbl_var_str = 'MEPAUC_uV_ms';
		app.(axes_str).YLabel.String = 'MEP AUC (�V*ms)';
	case 'Peak-to-Peak'
		app.h_emg_auc_patch.Visible = 'off';
		tbl_var_str = 'MEPAmpl_uVPp';
		app.(axes_str).YLabel.String = 'MEP Vp-p (�V)';
end


app.(axes_str).YLabel.String;
for row_cnt = 1:height(app.(axes_str).UserData)
	h_line = find_rc_datapoint(app.(axes_str), row_cnt);
	h_line.YData = app.(axes_str).UserData.(tbl_var_str)(row_cnt);
end