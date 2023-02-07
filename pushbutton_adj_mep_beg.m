function pushbutton_adj_mep_beg(src, evt, app) %#ok<INUSL>
% mep begin line should be before when the mep begins
% If more than 1 epoch is chosen then the mean_mep_line is used
% This function will move the line right to the where the emg data first
% crosses the std dev interval.


% disp('pushbutton_adj_mep_beg')
mep_beg_time = app.h_t_min_line.XData(1);

% mean_emg_data line
h_mean_mep_line = findobj(app.h_disp_emg_axes, 'Tag', 'mean_mep_line');
if isempty(h_mean_mep_line)
	disp('No mean MEP line. Using single sample EMG data.')

	h_mean_mep_line = app.h_emg_line;

end

% use a spline approximation of the emg_line for finer resolution
finer_interval = (h_mean_mep_line.XData(2) - h_mean_mep_line.XData(1)) / 100;
x_spline = h_mean_mep_line.XData(1) : finer_interval : h_mean_mep_line.XData(end);
y_spline = spline(h_mean_mep_line.XData, h_mean_mep_line.YData, x_spline);

% 2022-12-14: new method looking at when the MEP exceeds the std dev interaval lines

% examine mean mep line, find first time after the current mep begin line when mean mep exceeds
% the std dev window
std_dev_value = app.h_pre_stim_emg_pos_std_line.YData(1);
% mep_beg_ind = find(h_mean_mep_line.XData > mep_beg_time & abs(h_mean_mep_line.YData) >= std_dev_value, 1, 'first');
mep_beg_ind = find(x_spline > mep_beg_time & abs(y_spline) >= std_dev_value, 1, 'first');
mep_begin = x_spline(mep_beg_ind);

% change the mep start line
if mep_begin ~= mep_beg_time
% 	fprintf('  MEP beg changed from %f to %f\n', mep_beg_time, mep_begin)
	app.h_t_min_line.XData = [mep_begin mep_begin];
	mep_line_drag_endfcn(app.h_t_min_line)
end
% if the value has changed from the one stored in the app (most likely from
% being read in from the info file)
if abs(app.mep_info.mep_beg_t - mep_begin) > 0.05 
	% update info and flag it to be saved
	% update the analysis date
	app.h_edit_mep_done_when.String = datestr(now, 'yyyy-mm-dd HH:MM:SS'); %#ok<DATST,TNOW1> 
	% update done by
	app.h_edit_mep_done_by.String = app.user_initials;
	app.mep_times_changed_flag = true;
end

return
end % pushbutton_adj_mep_beg