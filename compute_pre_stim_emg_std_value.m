function std_val = compute_pre_stim_emg_std_value(app, emg_data)

left_time = app.preEmgMinEditField.Value; % time interval read in from parameter file
right_time = app.preEmgMaxEditField.Value; 
pre_stim_data = emg_data.YData(emg_data.XData>=left_time ...
	& emg_data.XData<right_time);

std_val = std(pre_stim_data);

end