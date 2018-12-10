function rc_dp_tbl_select_callback(h_tbl, cell_edit_data, app)

% cell_edit_data:
% Indices
% PreviousData
% EditData - user entered value
% NewData - value ML wrote to Data property array
% Error - error msg if enrro in user entered data
% Source 
% EventName = 'CellEdit'

if cell_edit_data.Indices(2) == 2 % col2 'Use' edited
	h_line = find_rc_datapoint(app.rc_axes, cell_edit_data.Indices(1));
	% get uimenu
	if cell_edit_data.EditData
		enable_disable_str = 'Enable';
	else
		enable_disable_str = 'Disable';
	end
	for h_cnt = 1:length(h_line.UIContextMenu.Children)
		if strcmp(h_line.UIContextMenu.Children(h_cnt).Label, enable_disable_str)
			h_menu = h_line.UIContextMenu.Children(h_cnt);
		end
	end
	
	data_point_enable_disable(h_menu, [], h_line, app.rc_axes)
end