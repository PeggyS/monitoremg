function rc_dp_tbl_select_callback(h_tbl, cell_select_data, app)

% cell_select_data:
% Indices
% Source 
% EventName = 'CellSelection'

if ~isempty(cell_select_data.Indices)
	new_row = cell_select_data.Indices(1);
else
	new_row = [];
	app.row_displayed = 0;
end

if isempty(new_row) 
	return
end
if new_row == app.row_displayed
	return
end

% display emg data
app.h_emg_line.YData = app.emg_data(new_row, 2:end);
app.h_disp_emg_axes.YLim = [min(app.emg_data(new_row, 2:end)) max(app.emg_data(new_row, 2:end))];
app.row_displayed = new_row;

% highlight data point in rc_fig
h_line = find_rc_datapoint(app.rc_axes, new_row);
if ~isempty(h_line)
	clr = [0 0.8 0];
	if h_tbl.Data{new_row, 6} > h_tbl.Data{new_row, 9}
		clr = [170 100 245]/255;
	elseif h_tbl.Data{new_row, 6} < h_tbl.Data{new_row, 7}
		clr = [255 193 59]/255;
	end
	h_line.Color = clr;
	h_line.MarkerSize = 50;
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
