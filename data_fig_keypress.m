function data_fig_keypress(src, key_data, app)
disp(key_data.Key)
app.h_uitable.UserData.Selection

switch key_data.Key
	case 'downarrow'
		cell_select_data.Indices = app.h_uitable.UserData.Selection(end,:);
		cell_select_data.Indices(1) = min([cell_select_data.Indices(1) + 1, size(app.h_uitable.Data,1)]);
	case 'uparrow'
		cell_select_data.Indices = app.h_uitable.UserData.Selection(1,:);
		cell_select_data.Indices(1) = max([cell_select_data.Indices(1) - 1, 1]);
	otherwise
		cell_select_data.Indices = app.h_uitable.UserData.Selection;
end

cell_select_data.Source = src;
cell_select_data.EventName = 'CellSelection';

rc_dp_tbl_select_callback(app.h_uitable, cell_select_data, app)
end