function pushbutton_adj_mep_beg_old_method(src, evt, app) %#ok<INUSL>
% mep begin line should be after when the mep begins
% This function will move the line left the local min or max, approximating
% the derivative = 0.
% 2023-02-08: change function so it will only work when a single epoch is
% chosen. Will not work on the mean_emg_line

% disp('pushbutton_adj_mep_beg')
mep_beg_time = app.h_t_min_line.XData(1);

% mean_emg_data line
h_mean_mep_line = findobj(app.h_disp_emg_axes, 'Tag', 'mean_mep_line');
if ~isempty(h_mean_mep_line)
	disp('button only works with a single emg trace chosen')
end

% use a spline approximation of the emg_line for finer resolution
finer_interval = (app.h_emg_line.XData(2) - app.h_emg_line.XData(1)) / 100;
x_spline = app.h_emg_line.XData(1) : finer_interval : app.h_emg_line.XData(end);
y_spline = spline(app.h_emg_line.XData, app.h_emg_line.YData, x_spline);

% =====================================================
% old method of looking at the derivative of the mean line
% look at derivative (diff) of YData 
% find when derivative is 0
y_diff = diff(y_spline);

% index of the current mep_beg_time
mep_beg_ind = find(x_spline >= mep_beg_time, 1, 'first');

% is the derivative at current mep_beg_time > or < 0
while y_diff(mep_beg_ind) == 0 % ensure the deriv is not exactly 0
	mep_beg_ind = mep_beg_ind - 1;
end
if y_diff(mep_beg_ind) < 0
	localmin_maxfcn = 'islocalmax';
else
	localmin_maxfcn = 'islocalmin';
end

% find the local min or max before mep_beg_ind
% vec = islocalmin(h_mean_mep_line.YData);
min_max_vec = feval(localmin_maxfcn, y_spline); %#ok<FVAL> 
peak_ind = find(min_max_vec(1:mep_beg_ind) == true, 1, 'last');
mep_begin = x_spline(peak_ind);


% change the mep start line
if mep_begin ~= mep_beg_time
% 	fprintf('  MEP beg changed from %f to %f\n', mep_beg_time, mep_begin)
	app.h_t_min_line.XData = [mep_begin mep_begin];
	latency_col = find(contains(app.h_uitable.ColumnName, '>latency<'));
	%  get selected row in the table
	selected_row = str2double(app.h_edit_epoch.String);
	% update latency
	app.h_uitable.Data(selected_row, latency_col) = {mep_begin};
	% update mep amplitude
	update_table_mep_amplitude(app, selected_row)
	% reselect table row
	select_table_rows(app.h_uitable, selected_row-1)
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