function pushbutton_adj_mep_beg(src, evt, app) %#ok<INUSL>
% mep begin line should be after when the mep begins
% There must be more than 1 epoch chosen so there is a mean_mep_line.
% This function will move the line left to the best approximation of the
% mep begin time.
% FIXME - more description of the algorithm:
%	move the 

disp('pushbutton_adj_mep_beg')
mep_beg_time = app.h_t_min_line.XData(1);

% mean_emg_data line
h_mean_mep_line = findobj(app.h_disp_emg_axes, 'Tag', 'mean_mep_line');
if isempty(h_mean_mep_line)
	disp('There must be more than 1 epoch chosen to adjust the MEP begin line.')
	return
end

% look at derivative (diff) of YData 
% find when derivative is 0
y_diff = diff(h_mean_mep_line.YData);

% look backwards in time from the current mep_beg_time
mep_beg_ind = find(h_mean_mep_line.XData >= mep_beg_time, 1, 'first');

% is the derivative at current mep_beg_time > or < 0
while y_diff(mep_beg_ind) == 0 % ensure the deriv is not exactly 0
	mep_beg_ind = mep_beg_ind + 1;
end
if y_diff(mep_beg_ind) < 0
	y_diff_less_than_zero = true;
else
	y_diff_less_than_zero = false;
end

if y_diff_less_than_zero
	search_ind = find(y_diff(1:mep_beg_ind) >= 0, 1, 'last');	
else
	search_ind = find(y_diff(1:mep_beg_ind) < 0, 1, 'last');
end

% if y_diff(search_ind) == 0
% 	mep_begin = h_mean_mep_line.XData(search_ind);
% else
% 	t_before_zero = h_mean_mep_line.XData(search_ind);
% 	t_after_zero =  h_mean_mep_line.XData(search_ind+1);
% 	val_before_zero = y_diff(search_ind);
% 	val_after_zero = y_diff(search_ind+1);
% 	% linear interpolate to find the time that crosses zero
% 	mep_begin = interp1([val_before_zero val_after_zero], [t_before_zero t_after_zero], 0);
% end	

% from this mep_begin time, look further to the left for the next peak on the line
if y_diff_less_than_zero
	second_search_ind = find(y_diff(1:search_ind) <= 0, 1, 'last');
else
	second_search_ind = find(y_diff(1:search_ind) >= 0, 1, 'last');
end

val_at_peak_before_mep = h_mean_mep_line.YData(second_search_ind);
% use this as a threshold - looking to the right of the new mep begin, 
% find when the abs mean mep exceeds this value
if y_diff_less_than_zero
	third_search_ind = find(h_mean_mep_line.YData(1:mep_beg_ind) >= val_at_peak_before_mep, 1, 'last');
else
	third_search_ind = find(h_mean_mep_line.YData(1:mep_beg_ind) <= val_at_peak_before_mep, 1, 'last');
end

% new mep begin index is the next point
mep_begin = h_mean_mep_line.XData(third_search_ind+1);
assert(~isnan(mep_begin), 'pushbutton_adj_mep_beg: mep_begin computed as nan')
assert(~isempty(mep_begin), 'pushbutton_adj_mep_beg: mep_begin computed as empty')

% change the mep start line
if mep_begin ~= mep_beg_time
	fprintf('  MEP beg changed from %f to %f\n', mep_beg_time, mep_begin)
	app.h_t_min_line.XData = [mep_begin mep_begin];
	mep_line_drag_endfcn(app.h_t_min_line)
	% update the analysis date
	app.h_edit_mep_done_when.String = datestr(now, 'yyyy-mm-dd');
	app.mep_times_changed_flag = true;
	% update done by
	app.h_edit_mep_done_by.String = app.AnalysisdonebyEditField.Value;
end

return
end % pushbutton_adj_mep_beg