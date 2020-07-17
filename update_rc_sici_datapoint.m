function update_rc_sici_datapoint(app, table_row_num, mep_val, auc)

if isgraphics(app.rc_axes)
	axes_str = 'rc_axes';
elseif isgraphics(app.sici_axes)
	axes_str = 'sici_axes';
else
	return
end

% update table with MEPAmpl & auc
app.(axes_str).UserData.MEPAmpl_uVPp(table_row_num) = mep_val;
app.(axes_str).UserData.MEPAUC_uV_ms(table_row_num) = auc;


% find out if app is displaying MEP ampl or auc
if isprop(app, 'h_radio_mep')
	for kk = 1:length(app.h_radio_mep.Children)
		if app.h_radio_mep.Children(kk).Value
			tag = app.h_radio_mep.Children(kk).Tag; % tag of selected radio button (either rb_mep_ampl, or rb_mep_auc)
		end
	end
end
switch tag
	case 'rb_mep_ampl'
		new_display_value = mep_val;
	case 'rb_mep_auc'
		new_display_value = auc;
end

% update the line in the figure
h_line = find_rc_datapoint(app.(axes_str), table_row_num);
h_line.YData = new_display_value;

if isgraphics(app.sici_axes)
	% update mean sd & ci lines
	stim_type = app.sici_axes.UserData.Stim_Type{table_row_num};
	switch stim_type
		case 'Test Stim'
			info_var = 'ts';
		case 'SICI'
			info_var = 'sici';
		case 'ICF'
			info_var = 'icf';
	end
	
	update_sici_mean_sc_ci_lines(app, stim_type, info_var)
	
end