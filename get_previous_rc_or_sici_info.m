function get_previous_rc_or_sici_info(app)

if app.CheckBoxRc.Value == 1
	fname = get_rc_fit_info_file_name(app);
	app.rc_fit_info = read_fit_info(fname);
	% display the info
	if isfield(app.rc_fit_info, 'analyzed_by')
		app.AnalyzedbyEditField.Value = upper(app.rc_fit_info.analyzed_by);
	else
		app.AnalyzedbyEditField.Value = '???';
	end
	if isfield(app.rc_fit_info, 'analyzed_when')
		app.AnalyzedWhenEditField.Value = app.rc_fit_info.analyzed_when;
	else
		app.AnalyzedWhenEditField.Value = '2022-00-00';
	end
	if isfield(app.rc_fit_info, 'slope')
		display_rc_fit_info_on_axes(app)
	end
end % rc


if app.CheckBoxSici.Value == 1
	fname = get_rc_fit_info_file_name(app);
	fname = strrep(fname, '_fit_', '_sici_');
	app.sici_info = read_sici_info(fname);
	% display the info
	if isfield(app.sici_info, 'analyzed_by')
		app.AnalyzedbyEditField.Value = upper(app.sici_info.analyzed_by);
	else
		app.AnalyzedbyEditField.Value = '???';
	end
	if isfield(app.sici_info, 'analyzed_when')
		app.AnalyzedWhenEditField.Value = app.sici_info.analyzed_when;
	else
		app.AnalyzedWhenEditField.Value = '2022-00-00';
	end
	if isfield(app.sici_info, 'ts_n')
% 		display_rc_fit_info_on_axes(app)
	end
end % sici


return
end