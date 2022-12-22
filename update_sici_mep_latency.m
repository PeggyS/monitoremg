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

end
