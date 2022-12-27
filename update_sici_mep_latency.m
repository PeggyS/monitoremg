function update_sici_mep_latency(app, info_var, epochs_used)

% get the mep latency /begin and end
mep_start_time = app.h_t_min_line.XData(1);
mep_end_time = app.h_t_max_line.XData(1);

% update the displayed number
str_format = '%4.1f';
app.sici_ui.([info_var '_latency']).String = num2str(mep_start_time, str_format);

% update the user data
app.sici_ui.([info_var '_latency']).UserData.mep_beg_t = mep_start_time;
app.sici_ui.([info_var '_latency']).UserData.mep_end_t = mep_end_time;
app.sici_ui.([info_var '_latency']).UserData.epochs_used = epochs_used;
app.sici_ui.([info_var '_latency']).UserData.num_sd = str2double(app.h_num_std.String);

% update review figure fields
if isprop(app, 'mep_info')
	% make sure data used is the same as the type of data being viewed now
	if isfield(app.mep_info, 'using_rc_or_sici_data')
		if isempty(app.mep_info.using_rc_or_sici_data)
			app.mep_info.using_rc_or_sici_data = 'sici';
			% update the analysis date
			app.h_edit_mep_done_when.String = datestr(now, 'yyyy-mm-dd HH:MM:SS');
			% update done by
			app.h_edit_mep_done_by.String = app.user_initials;
			app.mep_times_changed_flag = true;
			% using data
			app.h_using_data_txt.String = ['Using ' upper(info_var) ' sici data'];
		end
	end

	% if the value has changed from the one stored in the app (most likely from
	% being read in from the info file)
	if isfield(app.mep_info, 'mep_beg_t') && abs(app.mep_info.mep_beg_t - app.h_t_min_line.XData(1)) > 0.05
		% update info and flag it to be saved
		% update the analysis date
		app.h_edit_mep_done_when.String = datestr(now, 'yyyy-mm-dd HH:MM:SS');
		% update done by
		app.h_edit_mep_done_by.String = app.user_initials;
		app.mep_times_changed_flag = true;
		% using data
		app.h_using_data_txt.String = ['Using ' upper(info_var) ' sici data'];
	end
end % mep_info

end % function
