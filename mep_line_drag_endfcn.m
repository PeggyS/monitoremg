function mep_line_drag_endfcn(h_line)
% h_line.UserData = app
app = h_line.UserData;

% get min & max line x values
mep_start_time = app.h_t_min_line.XData(1);
mep_end_time = app.h_t_max_line.XData(1);

% update values in the EMG Data figure
app.h_edit_mep_begin.String = num2str(mep_start_time, '%.2f');
app.h_edit_mep_end.String = num2str(mep_end_time, '%.2f');
t_dur = mep_end_time - mep_start_time;
app.h_edit_mep_dur.String = num2str(t_dur, '%.2f');

% get the selected rows, so if values change and cells become unselected,
% they can be reselected
% reselect the cells (if needed)
jUIScrollPane = findjobj(app.h_uitable);
jUITable = jUIScrollPane.getViewport.getView;
j_original_selected_rows = jUITable.getSelectedRows;
if isempty(j_original_selected_rows)
	return
end
% if ~isempty(j_original_selected_rows)
% 	fprintf('mep_line_drag_endfcn: original table cells selected: %s\n', mat2str(j_original_selected_rows))
% end

% recompute the MEP peak to peak value and MEPAUC for 
% all rows in the data point table if rc display
% rows with matching stimulator values (stim type) if sici display
if app.CheckBoxSici.Value == true % doing sici
	% find the column indices in the table
	magstim_col = find(contains(app.h_uitable.ColumnName, '>MagStim<'));
	bistim_col = find(contains(app.h_uitable.ColumnName, '>BiStim<'));
	isi_col = find(contains(app.h_uitable.ColumnName, '>ISI<'));

	% get stimulator settings
	magstim_val = app.h_uitable.Data{j_original_selected_rows(1)+1, magstim_col};
	bistim_val = app.h_uitable.Data{j_original_selected_rows(1)+1, bistim_col};
	isi_val = app.h_uitable.Data{j_original_selected_rows(1)+1, isi_col};

	% find all rows in the table with these stimulator settings
	m_rows = find(cell2mat(app.h_uitable.Data(:, magstim_col)) == magstim_val);
	b_rows = find(cell2mat(app.h_uitable.Data(:, bistim_col)) == bistim_val);
	i_rows = find(cell2mat(app.h_uitable.Data(:, isi_col)) == isi_val);

	tmp_rows = intersect(m_rows, b_rows);
	row_indices = intersect(tmp_rows, i_rows)';
	
	% if ISI > 0, shift the data by ISI ms
	isi_ms = app.h_uitable.Data{j_original_selected_rows(1)+1, isi_col};
	isi_shift_pts = 0;
	if isi_ms > 0
		isi_shift_pts = round(app.params.sampFreq * isi_ms / 1000);
	end
elseif app.CheckBoxRc.Value == true % doing rc
	row_indices = 1:length(app.h_uitable.Data);
	isi_shift_pts = 0;
end


emg.XData = app.h_emg_line.XData;
for row_cnt = row_indices
	
	% get mep p-p  value 	
	tmp_data = app.emg_data(row_cnt, app.emg_data_num_vals_ignore+1:end);
	emg.YData = [tmp_data(isi_shift_pts+1:end) nan(1,isi_shift_pts)];
	
	mep_seg = emg.YData(emg.XData >= mep_start_time & emg.XData <= mep_end_time);
	mep_val = round(max(mep_seg) - min(mep_seg)); % 2022-07-22 added round
	if app.SubtractPreEMGppButton.Value % subtract the pre stim emg
		% compute the pre-stim emg
% 		emg.YData = app.emg_data(row_cnt, app.emg_data_num_vals_ignore:end);
		pre_stim_val = compute_pre_stim_emg_value(app, emg);
		mep_val = round(mep_val - pre_stim_val); % 2022-07-22 added round
	end
	
	% AUC
	[vertices, faces] = compute_patch(mep_start_time, mep_end_time, emg, 0);
	
	% if this row is being shown, update the patch
	if row_cnt == app.row_displayed
		app.h_emg_auc_patch.Vertices = vertices;
		app.h_emg_auc_patch.Faces = faces;
	end
	
	auc = round(compute_auc(vertices)); % 2022-07-22 added round
	
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
% 	fprintf('mep_line_drag_endfcn: table cells unselected .. reselecting them\n')
	for r_cnt = 1:length(j_original_selected_rows)
		row = j_original_selected_rows(r_cnt);
		col = 1;
		jUITable.changeSelection(row,col-1, true, false);
	end
else
% 	fprintf('mep_line_drag_endfcn: table cells stayed selected\n')
end

if isprop(app, 'sici_ui') && isfield(app.sici_ui, 'ts_latency') && isgraphics(app.sici_axes)
	stim_type = app.sici_axes.UserData.Stim_Type{j_original_selected_rows(r_cnt)};
	switch stim_type
		case 'Test Stim'
			info_var = 'ts';
		case 'SICI'
			info_var = 'sici';
		case 'ICF'
			info_var = 'icf';
	end
	update_sici_mep_latency(app, info_var, j_original_selected_rows'+1)
end

end %function


