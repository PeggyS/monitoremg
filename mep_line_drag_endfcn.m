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
	
% recompute the MEP peak to peak value and MEPAUC for all rows in the data point table
emg.XData = app.h_emg_line.XData;
for row_cnt = 1:length(app.h_uitable.Data)
	
	% get mep p-p  value 	
	mep_seg = app.emg_data(row_cnt, ind_mep_min+1:ind_mep_max+1); % +1 because 1st value in emg_data is magstim value

	mep_val = max(mep_seg) - min(mep_seg);
	
	if app.h_uitable.Data{row_cnt, 4} ~= mep_val
		% update the table 
		app.h_uitable.Data{row_cnt, 4} = mep_val;
		% update info in rc_fig
		update_rc_sici_datapoint(app, row_cnt, mep_val);
	end
	
	% AUC
	pre_stim_col = find_uitable_column(app.h_uitable, 'PreStim');
	pre_stim_val = app.h_uitable.Data{row_cnt,pre_stim_col};
% 	app.h_pre_stim_emg_line.YData = [pre_stim_val pre_stim_val];

	% update emg auc patch
	mep_start_time = app.h_t_min_line.XData(1);
	mep_end_time = app.h_t_max_line.XData(1);
	emg.YData = app.emg_data(row_cnt, app.emg_data_num_vals_ignore:end);
	[vertices, faces] = compute_patch(mep_start_time, mep_end_time, emg, pre_stim_val);
	
	% if this row is being shown, update the patch
	if row_cnt == app.row_displayed
		app.h_emg_auc_patch.Vertices = vertices;
		app.h_emg_auc_patch.Faces = faces;
	end
	
	auc = compute_auc(vertices);
	if app.h_uitable.Data{row_cnt, 5} ~= auc
		app.h_uitable.Data{row_cnt, 5} = auc;
		% FIX ME
% 		update_rc_sici_datapoint(app, row_cnt, auc);
	end

end

