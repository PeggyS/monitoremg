function pre_stim_val = compute_pre_stim_emg_value(app, emg_data)

left_time = app.preEmgMinEditField.Value; % 100 ms prior to stim (+ 1 ms to allow for stim artifact)
right_time = app.preEmgMaxEditField.Value; 
pre_stim_data = emg_data.YData(emg_data.XData>=left_time ...
	& emg_data.XData<right_time);
if app.MeanRectifiedValueButton.Value
	pre_stim_val = mean(abs(pre_stim_data) - mean(pre_stim_data));
else % using max peak to peak value
	pre_stim_val = max(pre_stim_data) - min(pre_stim_data);
end