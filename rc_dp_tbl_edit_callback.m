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
mep_adj_latency_col = find(contains(app.h_uitable.ColumnName, '>Latency<'));
mep_adj_end_col = find(contains(app.h_uitable.ColumnName, '>End<'));

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
		update_rc_sici_datapoint(app, table_row, [], [], true)
% 		mep_line_drag_endfcn(app.h_t_min_line)
	case {magstim_col, bistim_col}
		fprintf('rc_dp_tbl_edit_callback: table row %d, col %d edited\n', table_row, table_col)
		update_rc_sici_datapoint(app, table_row, [], [], true)
	case mep_adj_latency_col
		app.h_chkbx_adjust_mep_beg.Value = h_tbl.Data{table_row, table_col};
	case mep_adj_end_col
		app.h_chkbx_adjust_mep_end.Value = h_tbl.Data{table_row, table_col};

% 	otherwise
% 		beep
% 		fprintf('rc_dp_tbl_edit_callback: unkown row %d, col %d edited\n', table_row, table_col)
end
return