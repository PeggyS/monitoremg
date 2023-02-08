function rc_dp_tbl_select_callback(h_tbl, cell_select_data, app)

% cell_select_data:
% Indices
% Source 
% EventName = 'CellSelection'
persistent most_recent_selected all_selected 
%just_called_mep_line_drag_endfcn
% if just_called_mep_line_drag_endfcn == true
% 	% cell selection changed because mep_line_drag_endfcn changed values in
% 	% the table and no cells are selected
% 	return
% end

% fprintf('rc_dp_tbl_select_callback: start: cell_select: %s\n', mat2str(cell_select_data.Indices))
% fprintf('start: h_lines:  %s\n', mat2str(h_lines))

% remove previous lines
h_l = findobj('Tag', 'emg_select_line');
if ~isempty(h_l)
	delete(h_l)
end
h_l = findobj('Tag', 'mean_mep_line');
if ~isempty(h_l)
	delete(h_l)
end

h_lines = [];


new_row_to_show = most_recent_selected;
% fprintf('rc_dp_tbl_select_callback: start: most_recent: %d, all_selected: %s\n', most_recent_selected, mat2str(all_selected))

if ~isempty(cell_select_data.Indices)
	selected_rows = cell_select_data.Indices(:,1);
% 	fprintf('rc_dp_tbl_select_callback: Indices = %s\n', mat2str(selected_rows))
else
	return
end

new_rows_selected = setdiff(selected_rows, all_selected);

if ~isempty(new_rows_selected)
	% rows were added
	new_row_to_show = new_rows_selected(end);
	most_recent_selected = new_row_to_show;
else
	% rows were removed
	rows_removed = setdiff(all_selected, selected_rows);
	if any(rows_removed == most_recent_selected)
		new_row_to_show = selected_rows(end);
		most_recent_selected = new_row_to_show;
	end
end

% if new_row_to_show == app.row_displayed
% 	return
% end

% update epoch number under the axes
app.h_edit_epoch.String = num2str(new_row_to_show);

% update the mep begin & end editboxes and lines from the uitable values
latency_col = find(contains(app.h_uitable.ColumnName, '>latency<'));
mep_end_col = find(contains(app.h_uitable.ColumnName, '>end<'));
% if latency or end are nan, then use default values 10 and 90
if isnan(app.h_uitable.Data{new_row_to_show,latency_col})
	latency = 10;
	% get currently selected rows
	j_now_selected_rows = get_table_selected_rows(app.h_uitable);  % zero indexed
	% put default value in the table
	app.h_uitable.Data(new_row_to_show,latency_col) = {latency};
	% changing something in the table unselects the row, so reselect them
% 	disp('change latency to default. reselect table row')
	select_table_rows(app.h_uitable, j_now_selected_rows)
	
else
	latency = app.h_uitable.Data{new_row_to_show,latency_col};
end
if isnan(app.h_uitable.Data{new_row_to_show,mep_end_col})
	mep_end = 90;
	% get currently selected rows
	j_now_selected_rows = get_table_selected_rows(app.h_uitable);  % zero indexed
	% put default value in the table
	app.h_uitable.Data(new_row_to_show, mep_end_col) = {mep_end};
	% changing something in the table unselects the row, so reselect them
% 	disp('change mep_end to default. reselect table row')
	select_table_rows(app.h_uitable, j_now_selected_rows)
else
	mep_end = app.h_uitable.Data{new_row_to_show, mep_end_col};
end
% move the mep lines
app.h_t_min_line.XData = [latency latency];
app.h_t_max_line.XData = [mep_end mep_end];
% update edit boxes
app.h_edit_mep_begin.String = num2str(latency, '%.2f');
app.h_edit_mep_end.String = num2str(mep_end, '%.2f');
t_dur = mep_end - latency;
app.h_edit_mep_dur.String = num2str(t_dur, '%.2f');

% update emg data
update_review_emg_data_line(app, h_tbl, new_row_to_show)

all_selected = selected_rows;

% find the ISI (from the table)
isi_col = find(contains(app.h_uitable.ColumnName, '>ISI<'));


% if more than 1 row is selected, show all selected and the mean
if length(all_selected) > 1
	ymin = 0;
	ymax = 0;
	y_data_matrix = [];
	
	% add a line for each selected row
	for l_cnt = 1:length(all_selected)
		row = all_selected(l_cnt);
		x = app.h_emg_line.XData;
		% shift the data by the ISI (time between conditioning stim and test stim)
		isi_ms = h_tbl.Data{row, isi_col}; %#ok<FNDSB>
		% if sici/icf and ISI > 0, shift the data by ISI ms
		if app.CheckBoxSici.Value == 1 && isi_ms > 0
			isi_shift_pts = round(app.params.sampFreq * isi_ms / 1000);
		else
			isi_shift_pts = 0;
		end
		tmp_data = app.emg_data(row, app.emg_data_num_vals_ignore+1:end);
		y = [tmp_data(isi_shift_pts+1:end) tmp_data(end)*ones(1,isi_shift_pts)];
		
		h_lines(l_cnt) = line(app.h_disp_emg_axes, x, y, 'Color', [0.8 0.8 0.8], 'Tag', 'emg_select_line'); %#ok<AGROW>
		ymin = min([ymin min(y)]);
		ymax = max([ymax max(y)]);
		y_data_matrix(l_cnt,:) = y; %#ok<AGROW> 
	end % each selected row
	% set y limits
	app.h_disp_emg_axes.YLim = [ymin ymax];
	% send them all behind the other lines
	uistack(h_lines, 'bottom')
	% mean line
	mean_emg = mean(y_data_matrix,1);
	% if rows with different ISI are selected, this could be wrong FIXME
	% increase the resolution on the mean line using spline interpolation
	fine_res_x = min(x) : diff(x(1:2))/10 : max(x);
	fine_res_mean_emg = spline(x, mean_emg, fine_res_x);
	h_mean_emg_line = line(app.h_disp_emg_axes, fine_res_x, fine_res_mean_emg, 'Color', 'k', 'LineWidth', 1.5, ...
		'Tag', 'mean_mep_line');
	h_lines(l_cnt+1) = h_mean_emg_line; %#ok<NASGU> 
	% compute mean prestim value for mean line
	pre_stim_val = compute_pre_stim_emg_value(app, h_mean_emg_line);
	app.h_pre_stim_emg_line.YData = [pre_stim_val pre_stim_val];

	std_val = compute_pre_stim_emg_std_value(app, h_mean_emg_line) * str2double(app.h_num_std.String);
% 	disp(['pre stim ' app.h_num_std.String '*std for mean epochs = ' num2str(std_val)])
	app.h_pre_stim_emg_pos_std_line.YData = [std_val std_val];
	app.h_pre_stim_emg_neg_std_line.YData = [-std_val -std_val];

end

% fprintf('rc_dp_tbl_select_callback: exit: most_recent: %d, all: %s\n', most_recent_selected, mat2str(all_selected))
% fprintf('exit: h_lines:  %s\n', mat2str(h_lines))

% effective SO col from the table
effective_so_col = find(contains(app.h_uitable.ColumnName, 'Effective'));
if ~isempty(effective_so_col)
	% update the MEP-max SO edit field
	so_list = h_tbl.Data(all_selected, effective_so_col);
	so = unique([so_list{:}]);
	if length(so) > 1
		disp('more than 1 stimulator setting chosen')
		app.h_edit_mep_max_so.String = '?';
	else
		app.h_edit_mep_max_so.String = num2str(so);
	end
end

% if sici/icf, update the mep begin and end times
if isgraphics(app.sici_fig)
	% stim type col from the table
	st_col = find(contains(app.h_uitable.ColumnName, 'Type'));
	st_list = h_tbl.Data(all_selected, st_col);
	if length(st_list) > 1
		st = unique(st_list);
		if length(st) > 1
			disp('more than 1 stim type chosen')
			beep
			return
		end
		st_var = lower(st{:});
	else
		st_var = lower(st_list{:});
	end	
	if strcmp(st_var, 'test stim')
		st_var = 'ts';
	end
	
	st_var_latency = [st_var '_latency'];
	% put mep latency times from sici figure latency userdata 
	if isfield(app.sici_ui, st_var_latency) && isfield(app.sici_ui.(st_var_latency).UserData, 'mep_beg_t')
		val = app.sici_ui.(st_var_latency).UserData.mep_beg_t;
		if abs(str2double(app.h_edit_mep_begin.String) - val) > 0.05
			app.h_edit_mep_begin.String = num2str(val);
			app.h_t_min_line.XData = [val val];
			dur = str2double(app.h_edit_mep_end.String) - val;
			app.h_edit_mep_dur.String = num2str(dur);
		end
		val = app.sici_ui.(st_var_latency).UserData.mep_end_t;
		if abs(str2double(app.h_edit_mep_end.String) - val) > 0.05
			app.h_edit_mep_end.String = num2str(val);
			app.h_t_max_line.XData = [val val];
			dur = val - str2double(app.h_edit_mep_begin.String);
			app.h_edit_mep_dur.String = num2str(dur);
		end
		if abs(str2double(app.h_num_std.String) - app.sici_ui.(st_var_latency).UserData.num_sd) > 0.5
			app.h_num_std.String = num2str(app.sici_ui.(st_var_latency).UserData.num_sd);
		end
		
		app.h_using_data_txt.String = ['Using ' upper(st_var) ' sici data'];
	end
end

end % function