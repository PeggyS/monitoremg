function mep_line_drag_endfcn(h_line)
% h_line.UserData = app
app = h_line.UserData;

% get min & max line x values
h_min_line = findobj(h_line.Parent, 'Tag', 'mep_min_line');
t_mep_min = h_min_line.XData(1);

h_max_line = findobj(h_line.Parent, 'Tag', 'mep_max_line');
t_mep_max = h_max_line.XData(1);

seg_time = (app.params.postTriggerTime + app.params.preTriggerTime) / 1000;
seg_num_points = round(app.params.sampFreq*seg_time);
t = (0:1/app.params.sampFreq:(seg_time-1/app.params.sampFreq))*1000 - app.params.preTriggerTime;

ind_mep_min = find(t>=t_mep_min, 1);
ind_mep_max = find(t<=t_mep_max, 1, 'last');
	
% recompute the MEP peak to peak value for all rows in the data point table
for row_cnt = 1:length(app.h_uitable.Data)
	
	% get mep value 	
	mep_seg = app.emg_data(row_cnt, ind_mep_min+1:ind_mep_max+1); % +1 because 1st value in emg_data is magstim value

	mep_val = max(mep_seg) - min(mep_seg);
	
	if app.h_uitable.Data{row_cnt, 4} ~= mep_val
		% update the table 
		app.h_uitable.Data{row_cnt, 4} = mep_val;
		% update info in rc_fig
		update_rc_datapoint(app, row_cnt, mep_val);
	end
end
