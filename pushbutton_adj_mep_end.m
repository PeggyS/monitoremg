function pushbutton_adj_mep_end(src, evt, app) %#ok<INUSL>
% mep end line should be before the last peak then ends the MEP
% This function will move the line left to when the emg data exceeds the
% std dev interval.
% 2023-02-08: change function so it will only work when a single epoch is
% chosen. Will not work on the mean_emg_line


% disp('pushbutton_adj_mep_end')
mep_end_time = app.h_t_max_line.XData(1);

% mean_emg_data line
h_mean_mep_line = findobj(app.h_disp_emg_axes, 'Tag', 'mean_mep_line');
if ~isempty(h_mean_mep_line)
	disp('button only works with a single emg trace chosen')
end

% use a spline approximation of the emg_line for finer resolution
finer_interval = (app.h_emg_line.XData(2) - app.h_emg_line.XData(1)) / 100;
x_spline = app.h_emg_line.XData(1) : finer_interval : app.h_emg_line.XData(end);
y_spline = spline(app.h_emg_line.XData, app.h_emg_line.YData, x_spline);

% 2022-12-14: new method looking at when the MEP exceeds the std dev interaval lines

% examine mean mep line, find first time after the current mep begin line when mean mep exceeds
% the std dev window
std_dev_value = app.h_pre_stim_emg_pos_std_line.YData(1);
mep_end_ind = find(x_spline < mep_end_time & abs(y_spline) >= std_dev_value, 1, 'last');
mep_end = x_spline(mep_end_ind);

if mep_end_time ~= mep_end
	% fprintf('  MEP end changed from %f to %f\n', mep_end_time, mep_end)
	% change the mep end line
	app.h_t_max_line.XData = [mep_end mep_end];
	mep_end_col = find(contains(app.h_uitable.ColumnName, '>end<'));
	%  get selected row in the table
	selected_row = str2double(app.h_edit_epoch.String);
	% update latency
	app.h_uitable.Data(selected_row, mep_end_col) = {mep_end};
	% update mep amplitude
	update_table_mep_amplitude(app, selected_row)
	% reselect table row
	select_table_rows(app.h_uitable, selected_row-1)
end
% if the value has changed from the one stored in the app (most likely from
% being read in from the info file)
if abs(app.mep_info.mep_end_t - mep_end) > 0.05 
	% update info and flag it to be saved
	% update the analysis date
	app.h_edit_mep_done_when.String = datestr(now, 'yyyy-mm-dd HH:MM:SS'); %#ok<DATST,TNOW1> 
	% update done by
	app.h_edit_mep_done_by.String = upper(app.user_initials);
	app.mep_times_changed_flag = true;
end
return
end % pushbutton_adj_mep_beg