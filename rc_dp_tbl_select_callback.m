function rc_dp_tbl_select_callback(h_tbl, cell_select_data, app)

% cell_select_data:
% Indices
% Source 
% EventName = 'CellSelection'

new_row = cell_select_data.Indices(1);

if new_row == app.row_displayed
	return
end

app.h_emg_line.YData = app.emg_data(new_row, 2:end);
app.h_disp_emg_axes.YLim = [min(app.emg_data(new_row, 2:end)) max(app.emg_data(new_row, 2:end))];
app.row_displayed = new_row;

