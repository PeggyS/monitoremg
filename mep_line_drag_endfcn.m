function mep_line_drag_endfcn(h_line)
% h_line.UserData = app
app = h_line.UserData;

% get min & max line x values
mep_start_time = app.h_t_min_line.XData(1);
mep_end_time = app.h_t_max_line.XData(1);

% update values in the EMG Data figure
app.h_edit_mep_begin.String = num2str(mep_start_time, 3);
app.h_edit_mep_end.String = num2str(mep_end_time, 3);
t_dur = mep_end_time - mep_start_time;
app.h_edit_mep_dur.String = num2str(t_dur, 3);

% get the selected rows, so if values change and cells become unselected,
% they can be reselected
% reselect the cells (if needed)
jUIScrollPane = findjobj(app.h_uitable);
jUITable = jUIScrollPane.getViewport.getView;
j_original_selected_rows = jUITable.getSelectedRows;
if ~isempty(j_original_selected_rows)
	fprintf('mep_line_drag_endfcn: original table cells selected: %s\n', mat2str(j_original_selected_rows))
end

% recompute the MEP peak to peak value and MEPAUC for all rows in the data point table
emg.XData = app.h_emg_line.XData;
for row_cnt = 1:length(app.h_uitable.Data)
	
	% get mep p-p  value 
	
	% find the ISI (from the table)
	isi_col = find(contains(app.h_uitable.ColumnName, '>ISI<'));
	isi_ms = app.h_uitable.Data{row_cnt, isi_col}; %#ok<FNDSB>
	
	% if ISI > 0, shift the data by ISI ms
	if app.CheckBoxSici.Value == 1 && isi_ms > 0
		isi_shift_pts = round(app.params.sampFreq * isi_ms / 1000);
	else
		isi_shift_pts = 0;
	end
	tmp_data = app.emg_data(row_cnt, app.emg_data_num_vals_ignore+1:end);
	emg.YData = [tmp_data(isi_shift_pts+1:end) nan(1,isi_shift_pts)];
	
	mep_seg = emg.YData(emg.XData >= mep_start_time & emg.XData <= mep_end_time);
	mep_val = max(mep_seg) - min(mep_seg);
	if app.SubtractPreEMGppButton.Value % subtract the pre stim emg
		% compute the pre-stim emg
% 		emg.YData = app.emg_data(row_cnt, app.emg_data_num_vals_ignore:end);
		pre_stim_val = compute_pre_stim_emg_value(app, emg);
		mep_val = mep_val - pre_stim_val;
	end
	
	% AUC
	[vertices, faces] = compute_patch(mep_start_time, mep_end_time, emg, 0);
	
	% if this row is being shown, update the patch
	if row_cnt == app.row_displayed
		app.h_emg_auc_patch.Vertices = vertices;
		app.h_emg_auc_patch.Faces = faces;
	end
	
	auc = compute_auc(vertices);
	
	% update the uitable
	mep_ampl_col = find(contains(app.h_uitable.ColumnName, '>MEPAmpl<'));
	mep_auc_col = find(contains(app.h_uitable.ColumnName, '>MEPAUC<'));
	if app.h_uitable.Data{row_cnt, mep_ampl_col} ~= mep_val || app.h_uitable.Data{row_cnt, mep_auc_col} ~= auc
		% update the table 
		app.h_uitable.Data{row_cnt, mep_ampl_col} = mep_val;
		app.h_uitable.Data{row_cnt, mep_auc_col} = auc;
		
		% update info in rc_fig
		update_rc_sici_datapoint(app, row_cnt, mep_val, auc, false);
	end
end

% reselect the cells (if needed)
jUIScrollPane = findjobj(app.h_uitable);
jUITable = jUIScrollPane.getViewport.getView;
j_now_selected_rows = jUITable.getSelectedRows;
if isempty(j_now_selected_rows)
	fprintf('mep_line_drag_endfcn: table cells unselected .. reselecting them\n')
	for r_cnt = 1:length(j_original_selected_rows)
		row = j_original_selected_rows(r_cnt);
		col = 1;
		jUITable.changeSelection(row,col-1, true, false);
	end
else
	fprintf('mep_line_drag_endfcn: table cells stayed selected\n')
end
% pause(0.1)

