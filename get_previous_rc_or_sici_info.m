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
	read_in_info = read_sici_info(fname);
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
		% compare info in sici figure - which were computed with the data
		% points read in - to what was saved in the file
		st_col = find(contains(app.h_uitable.ColumnName, '>Stim<'));
		st_list = unique(app.h_uitable.Data(:,st_col));
		for st_cnt = 1:length(st_list)
			st = lower(st_list{st_cnt});
			if contains(st, 'test')
				st = 'ts';
			end
			mean_var = [st '_mean'];
			if abs(app.sici_info.(mean_var) - read_in_info.(mean_var)) > eps
				fprintf('%s: figure value = %f; info file value = %f\n', ...
					mean_var, app.sici_info.(mean_var), read_in_info.(mean_var))
				disp('verify values and save as needed')
				beep
			else
				fprintf('%s: figure & info file value are the same\n', mean_var)
			end
		end

	else
		disp('no previous sici_info.txt read in')
	end
end % sici


return
end