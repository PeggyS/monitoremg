function rc_dp_tbl_select_callback(h_tbl, cell_select_data, app)

% cell_select_data:
% Indices
% Source 
% EventName = 'CellSelection'
persistent most_recent_selected all_selected h_lines

fprintf('start: most_recent: %d, all: %s\n', most_recent_selected, mat2str(all_selected))
% fprintf('start: h_lines:  %s\n', mat2str(h_lines))

% remove previous lines
if ~isempty(h_lines)
	delete(h_lines)
	h_lines = [];
end

new_row_to_show = most_recent_selected;

if ~isempty(cell_select_data.Indices)
	selected_rows = cell_select_data.Indices(:,1);
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

% update emg data
update_review_emg_data_line(app, h_tbl, new_row_to_show)

all_selected = selected_rows;

% if more than 1 row is selected, show all selected and the mean
if length(all_selected) > 1
	ymin = 0;
	ymax = 0;
	y_data_matrix = [];
	% add a line for each row
	for l_cnt = 1:length(all_selected)
		row = all_selected(l_cnt);
		x = app.h_emg_line.XData;
		% shift the data by the ISI (time between conditioning stim and test stim)
		% find the ISI (from the table)
		isi_col = find(contains(app.h_uitable.ColumnName, '>ISI<'));
		isi_ms = h_tbl.Data{row, isi_col}; %#ok<FNDSB>
		% if sici/icf and ISI > 0, shift the data by ISI ms
		if app.CheckBoxSici.Value == 1 && isi_ms > 0
			isi_shift_pts = round(app.params.sampFreq * isi_ms / 1000);
		else
			isi_shift_pts = 0;
		end
		tmp_data = app.emg_data(row, app.emg_data_num_vals_ignore+1:end);
		y = [tmp_data(isi_shift_pts+1:end) nan(1,isi_shift_pts)];
		
		h_lines(l_cnt) = line(x,y, 'Color', [0.8 0.8 0.8]);
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
	h_mean_emg_line = line(x, mean_emg, 'Color', 'k', 'LineWidth', 1.5, ...
		'Tag', 'mean_mep_line');
	h_lines(l_cnt+1) = h_mean_emg_line;
	% compute mean prestim value for mean line
	pre_stim_val = compute_pre_stim_emg_value(app, h_mean_emg_line);
	app.h_pre_stim_emg_line.YData = [pre_stim_val pre_stim_val];

	% if autocompute MEP times is checked
	if app.h_autocompute_mep.Value == 1
		% use the mean emg line
		abs_mean_emg = abs(mean_emg);
		[min_emg, min_emg_ind] = min(mean_emg, [], 'omitnan');
		[max_emg, max_emg_ind] = max(mean_emg, [], 'omitnan');
		% min index is the first peak
		min_ind = min([min_emg_ind max_emg_ind]);
		% search for the last time before the min_ind that is below the pre_stim_val
		search_ind = find(abs_mean_emg(1:min_ind) <= pre_stim_val, 1, 'last');
		if abs_mean_emg(search_ind) == pre_stim_val
			mep_begin = h_mean_emg_line.XData(search_ind);
		else
			% the next point will be above threshold
			threshold_ind = search_ind+1;
			abs_mean_emg(threshold_ind);
			h_mean_emg_line.XData(threshold_ind);
			t_before_thresh = h_mean_emg_line.XData(search_ind);
			t_after_thresh = h_mean_emg_line.XData(threshold_ind);
			val_before_thresh = abs_mean_emg(search_ind);
			val_after_thresh = abs_mean_emg(threshold_ind);
			% linear interpolate to find the time that crosses threshold
			mep_begin = interp1([val_before_thresh val_after_thresh], [t_before_thresh t_after_thresh], pre_stim_val);
			fprintf('auto computed mep begin t = %f\n', mep_begin)
		end
		% change the mep start line
		app.h_t_min_line.XData = [mep_begin mep_begin];
		mep_line_drag_endfcn(app.h_t_min_line)
		% save info used to compute mep_begin
		% save in the analysis folder with datapoints.csv file
		save_file = strrep(app.DatapointsCSVEditField.Value, 'datapoints.csv', 'mep_auto_compute_info.txt');
		info.mep_begin_time = mep_begin;
		info.epochs_used = all_selected;
		write_fit_info(save_file, info)
		fprintf('saved new mep auto compute file\n %s\n with mep begin time = %f\n', save_file, mep_begin)
	
	end
end

fprintf('exit: most_recent: %d, all: %s\n', most_recent_selected, mat2str(all_selected))
% fprintf('exit: h_lines:  %s\n', mat2str(h_lines))
