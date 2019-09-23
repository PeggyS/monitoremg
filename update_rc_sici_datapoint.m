function update_rc_sici_datapoint(app, table_row_num, mep_val)

if isgraphics(app.rc_axes)
	h_line = find_rc_datapoint(app.rc_axes, table_row_num);

	h_line.YData = mep_val/str2double(app.rc_fit_ui.edNormFactor.String) ;
	% make provision for MEPAUC - FIXME
	app.rc_axes.UserData.MEPAmpl_uVPp(table_row_num) = mep_val;
elseif isgraphics(app.sici_axes)
	h_line = find_rc_datapoint(app.sici_axes, table_row_num);

	h_line.YData = mep_val;
	% make provision for MEPAUC - FIXME
	app.sici_axes.UserData.MEPAmpl_uVPp(table_row_num) = mep_val;
	
	% update mean sd & ci linesswitch stim_type
	stim_type = app.sici_axes.UserData.Sici_or_icf_or_ts{table_row_num};
	switch stim_type
		case 'Test Stim'
			info_var = 'ts';
		case 'SICI'
			info_var = 'sici';
		case 'ICF'
			info_var = 'icf';
	end
	
	update_sici_mean_sc_ci_lines(app, stim_type, info_var)
	
else
	disp('no axes to update')
end