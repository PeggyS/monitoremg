function pushbutton_select_meps(source, event, app)
% for the selected row in the table, select all rows with the same
% stimulator settings that have mep data within the begin/end window
% exceeding their std dev lines

% get the currently selected table row
jUIScrollPane = findjobj(app.h_uitable);
jUITable = jUIScrollPane.getViewport.getView;
j_now_selected_rows = jUITable.getSelectedRows; % zero indexed
if isempty(j_now_selected_rows)
	disp('no table rows selected.')
	return
end
if length(j_now_selected_rows) > 1
	disp(['More than 1 row selected. Using row ' num2str(j_now_selected_rows(1)+1) ' stim values.'])
end
% toggle the current rows off
for r_cnt = 1:length(j_now_selected_rows)
	row = j_now_selected_rows(r_cnt);
	col = 1;
	% toggle the row
	jUITable.changeSelection(row,col-1, true, false);
end

% find the column indices in the table
% epoch_col = find(contains(app.h_uitable.ColumnName, 'Epoch'));
use_col = find(contains(app.h_uitable.ColumnName, 'Use'));
magstim_col = find(contains(app.h_uitable.ColumnName, '>MagStim<'));
bistim_col = find(contains(app.h_uitable.ColumnName, '>BiStim<'));
isi_col = find(contains(app.h_uitable.ColumnName, '>ISI<'));

% get stimulator settings
magstim_val = app.h_uitable.Data{j_now_selected_rows(1)+1, magstim_col};
bistim_val = app.h_uitable.Data{j_now_selected_rows(1)+1, bistim_col};
isi_val = app.h_uitable.Data{j_now_selected_rows(1)+1, isi_col};

% find all rows in the table with these stimulator settings
m_rows = find(cell2mat(app.h_uitable.Data(:, magstim_col)) == magstim_val);
b_rows = find(cell2mat(app.h_uitable.Data(:, bistim_col)) == bistim_val);
i_rows = find(cell2mat(app.h_uitable.Data(:, isi_col)) == isi_val);
u_rows = find(cell2mat(app.h_uitable.Data(:, use_col)) == 1);

tmp_rows = intersect(m_rows, b_rows);
tmp2_rows = intersect(tmp_rows, i_rows);
all_rows = intersect(tmp2_rows, u_rows);

% find only the rows that have mep data exceeding the std dev lines between
% mep_begin and mep_end
mep_rows = [];
isi_shift_pts = 0;
if app.CheckBoxSici.Value == 1 && isi_val > 0
	isi_shift_pts = round(app.params.sampFreq * isi_val / 1000);
end
% update conditioning stim line h_cs_line
app.h_cs_line.XData = -isi_val*[1 1];

% mep_begin & end times
mep_beg_time = app.h_t_min_line.XData(1);
mep_end_time = app.h_t_max_line.XData(1);
for r_cnt = 1:length(all_rows)
	this_row = all_rows(r_cnt);
	% this row's data
	tmp_data = app.emg_data(this_row, app.emg_data_num_vals_ignore+1:end);
	app.h_emg_line.YData = [tmp_data(isi_shift_pts+1:end) nan(1,isi_shift_pts)];

	std_val = compute_pre_stim_emg_std_value(app, app.h_emg_line) * str2double(app.h_num_std.String);
	if any(abs(app.h_emg_line.YData(app.h_emg_line.XData >= mep_beg_time & ...
		app.h_emg_line.XData <= mep_end_time)) > std_val)
		% data exceeds std val betw mep_beg_time & mep_end_time
		mep_rows = [mep_rows this_row]; %#ok<AGROW>
	end
end

% select those rows in the table
for r_cnt = 1:length(mep_rows)
	row = mep_rows(r_cnt);
	col = 1;
	% toggle the row
	jUITable.changeSelection(row-1, col-1, true, false);
end

end % function