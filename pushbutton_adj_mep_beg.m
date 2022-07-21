function pushbutton_adj_mep_beg(src, evt, app) %#ok<INUSL>


mep_beg_time = app.h_t_min_line.XData(1);

% mean_emg_data line
h_mean_mep_line = findobj(app.h_disp_emg_axes, 'Tag', 'mean_mep_line');


% look at derivative (diff) of YData 
% find when derivative is 0
y_diff = diff(h_mean_mep_line.YData);

% look backwards in time from the current mep_beg_time
mep_beg_ind = find(h_mean_mep_line.XData >= mep_beg_time, 1, 'first');

% is the derivative at current mep_beg_time > or < 0
if y_diff(mep_beg_ind) == 0
	% already at the deriv = 0 point
	return
elseif y_diff(mep_beg_ind) < 0
	y_diff_less_than_zero = true;
else
	y_diff_less_than_zero = false;
end

if y_diff_less_than_zero
	search_ind = find(y_diff(1:mep_beg_ind) > 0, 1, 'last');
	
else
	search_ind = find(y_diff(1:mep_beg_ind) < 0, 1, 'last');
end

if y_diff(search_ind) == 0
	mep_begin = h_mean_mep_line.XData(search_ind);
else
	t_before_zero = h_mean_mep_line.XData(search_ind);
	t_after_zero =  h_mean_mep_line.XData(search_ind+1);
	val_before_zero = y_diff(search_ind);
	val_after_zero = y_diff(search_ind+1);
	% linear interpolate to find the time that crosses zero
	mep_begin = interp1([val_before_zero val_after_zero], [t_before_zero t_after_zero], 0);
end	
	

% change the mep start line
app.h_t_min_line.XData = [mep_begin mep_begin];
mep_line_drag_endfcn(app.h_t_min_line)
return
end % pushbutton_adj_mep_beg