function pushbutton_adj_mep_end_old_method(src, evt, app) %#ok<INUSL>
% mep end line should be before the last peak then ends the MEP
% If more than 1 epoch is chosen then the mean_mep_line is used.
% This function will move the line right to the next local min or max,
% approximating when the derivative is zero.

% disp('pushbutton_adj_mep_end')
mep_end_time = app.h_t_max_line.XData(1);

% mean_emg_data line
h_mean_mep_line = findobj(app.h_disp_emg_axes, 'Tag', 'mean_mep_line');
if isempty(h_mean_mep_line)
	disp('No mean MEP line. Using single sample emg data.')
	h_mean_mep_line = app.h_emg_line;
end

% use a spline approximation of the emg_line for finer resolution
finer_interval = (h_mean_mep_line.XData(2) - h_mean_mep_line.XData(1)) / 100;
x_spline = h_mean_mep_line.XData(1) : finer_interval : h_mean_mep_line.XData(end);
y_spline = spline(h_mean_mep_line.XData, h_mean_mep_line.YData, x_spline);

% =====================================================
% old way using derivative of mean emg line
% look at derivative (diff) of YData 
% find when derivative is 0
y_diff = diff(y_spline);

%index of the current mep_end_time
mep_end_ind = find(x_spline >= mep_end_time, 1, 'first');

% is the derivative at current mep_end_time > or < 0
while abs(y_diff(mep_end_ind)) == 0 % ensure the deriv is not exactly 0
	mep_end_ind = mep_end_ind - 1;
end
if y_diff(mep_end_ind) < 0
	localmin_maxfcn = 'islocalmin';
else
	localmin_maxfcn = 'islocalmax';
end

% find the local min or max after mep_end_ind
min_max_vec = feval(localmin_maxfcn, y_spline); %#ok<FVAL> 
peak_ind = find(min_max_vec(mep_end_ind:end) == true, 1, 'first') + mep_end_ind-1;
mep_end = x_spline(peak_ind);


% if y_diff_less_than_zero
% 	search_ind = find(y_diff(mep_end_ind:end) >= 0, 1, 'first') + mep_end_ind-1;	
% else
% 	search_ind = find(y_diff(mep_end_ind:end) <= 0, 1, 'first') + mep_end_ind-1;
% end
% 
% if y_diff(search_ind) == 0
% 	mep_end = h_mean_mep_line.XData(search_ind);
% else
% 	t_before_zero = h_mean_mep_line.XData(search_ind-1);
% 	t_after_zero =  h_mean_mep_line.XData(search_ind);
% 	val_before_zero = y_diff(search_ind-1);
% 	val_after_zero = y_diff(search_ind);
% 	% linear interpolate to find the time that crosses zero
% 	mep_end = interp1([val_before_zero val_after_zero], [t_before_zero t_after_zero], 0);
% end	
% assert(~isnan(mep_end), 'pushbutton_adj_mep_end: mep_end computed as nan')
% assert(~isempty(mep_end), 'pushbutton_adj_mep_end: mep_end computed as empty')
% =====================================================

% % 2022-12-14: new method looking at when the MEP exceeds the std dev interaval lines
% % examine mean mep line, find first time after the current mep begin line when mean mep exceeds
% % the std dev window
% std_dev_value = app.h_pre_stim_emg_pos_std_line.YData(1);
% mep_end_ind = find(h_mean_mep_line.XData < mep_end_time & abs(h_mean_mep_line.YData) >= std_dev_value, 1, 'last');
% mep_end = h_mean_mep_line.XData(mep_end_ind);

if mep_end_time ~= mep_end
	% fprintf('  MEP end changed from %f to %f\n', mep_end_time, mep_end)
	% change the mep end line
	app.h_t_max_line.XData = [mep_end mep_end];
	mep_line_drag_endfcn(app.h_t_min_line)
end
% if the value has changed from the one stored in the app (most likely from
% being read in from the info file)
if abs(app.mep_info.mep_end_t - mep_end) > 0.05 
	% update info and flag it to be saved
	% update the analysis date
	app.h_edit_mep_done_when.String = datestr(now, 'yyyy-mm-dd HH:MM:SS'); %#ok<TNOW1,DATST> 
	% update done by
	app.h_edit_mep_done_by.String = upper(app.user_initials);
	app.mep_times_changed_flag = true;
end
return
end % pushbutton_adj_mep_beg