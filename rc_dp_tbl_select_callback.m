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

% update epoch number under the axes
app.h_edit_epoch.String = num2str(new_row);

update_review_emg_data_line(app, h_tbl, new_row)
