function rc_dp_tbl_select_callback(h_tbl, cell_select_data, app)

% cell_select_data:
% Indices
% Source 
% EventName = 'CellSelection'

if ~isempty(cell_select_data.Indices)
	new_row = cell_select_data.Indices(1);
else
	new_row = [];
	return
end

if isempty(new_row) 
	return
end
if new_row == app.row_displayed
	return
end

% display emg data
app.h_emg_line.YData = app.emg_data(new_row, app.emg_data_num_vals_ignore+1:end);
% if y limits are the same, make them wider
ymin = min(app.emg_data(new_row, app.emg_data_num_vals_ignore:end));
ymax = max(app.emg_data(new_row, app.emg_data_num_vals_ignore:end));
if ymax - ymin < eps
	ymax = ymax + 1;
	ymin = ymin - 1;
end
app.h_disp_emg_axes.YLim = [ymin ymax];
app.row_displayed = new_row;

% update pre-stim line
pre_stim_col = find_uitable_column(h_tbl, 'PreStim');
pre_stim_val = app.h_uitable.Data{new_row,pre_stim_col};
app.h_pre_stim_emg_line.YData = [pre_stim_val pre_stim_val];

% update emg auc patch
mep_start_time = app.h_t_min_line.XData(1);
mep_end_time = app.h_t_max_line.XData(1);
[vertices, faces] = compute_patch(mep_start_time, mep_end_time, app.h_emg_line, pre_stim_val);

app.h_emg_auc_patch.Vertices = vertices;
app.h_emg_auc_patch.Faces = faces;
auc = compute_auc(vertices);


% highlight data point in rc_fig or sici_fig
if isgraphics(app.rc_axes)
	h_ax = app.rc_axes;
elseif isgraphics(app.sici_axes)
	h_ax = app.sici_axes;
end
h_line = find_rc_datapoint(h_ax, new_row);
if ~isempty(h_line)
	clr = [0 0.8 0];
	emg_ind = find_uitable_column(h_tbl, 'MonitorEMG');
	emg_min_ind = find_uitable_column(h_tbl, 'Goal<br />Min');
	emg_max_ind = find_uitable_column(h_tbl, 'Goal<br />Max');
	if h_tbl.Data{new_row, emg_ind} > h_tbl.Data{new_row, emg_max_ind}
		clr = [170 100 245]/255;
	elseif h_tbl.Data{new_row, emg_ind} < h_tbl.Data{new_row, emg_min_ind}
		clr = [255 193 59]/255;
	end
	h_line.Color = clr;
	h_line.MarkerSize = 50;
	uistack(h_line,'top')
end
if ~isempty(app.rc_highlight_line)
	if isgraphics(app.rc_highlight_line)
		% unhighlight prev
		app.rc_highlight_line.Color = [0    0.4470    0.7410];
		if app.rc_highlight_line.Marker == 'x'
			app.rc_highlight_line.MarkerSize = 20;
		else
			app.rc_highlight_line.MarkerSize = 40;
		end
	end
end
% save highlighted line handle
app.rc_highlight_line = h_line;
