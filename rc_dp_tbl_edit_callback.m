function rc_dp_tbl_edit_callback(h_tbl, cell_edit_data, app)

% cell_edit_data:
% Indices
% PreviousData
% EditData - user entered value
% NewData - value ML wrote to Data property array
% Error - error msg if enrro in user entered data
% Source 
% EventName = 'CellEdit'

% find col num of some variables in the table
use_col = find(contains(cell_edit_data.Source.ColumnName, 'Use'));
isi_col = find(contains(cell_edit_data.Source.ColumnName, '>ISI<'));
magstim_col = find(contains(cell_edit_data.Source.ColumnName, '>MagStim<'));
bistim_col = find(contains(cell_edit_data.Source.ColumnName, '>BiStim<'));

table_row = cell_edit_data.Indices(1);
table_col = cell_edit_data.Indices(2);
switch table_col
	case use_col % 'Use' edited
		if isgraphics(app.rc_axes)
			h_ax = app.rc_axes;
		elseif isgraphics(app.sici_axes)
			h_ax = app.sici_axes;
		else
			return
		end
		h_line = find_rc_datapoint(h_ax, table_row);

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

		data_point_menu_callback(h_menu, [], h_line, h_ax)
	case isi_col  % ISI edited
		update_review_emg_data_line(app, h_tbl, table_row)
		mep_line_drag_endfcn(app.h_t_min_line)
	case magstim_col
	case bistim_col
		sprintf('rc_dp_tbl_edit_callback: bistim column %d edited', table_col)
		update_rc_sici_datapoint(app, table_row, [], [])
	otherwise
		beep
		sprintf('rc_dp_tbl_edit_callback: unkown column %d edited', table_col)
end
return