function add_point2rc(h_ax, table_row_num, magstim_val, mep_val)

h_line = line(h_ax, magstim_val, mep_val, ...
	'Marker', '.', 'MarkerSize', 40);
h_line.UserData.table_row_num = table_row_num;

drawnow
% context menu to disable/enable points
cmenu = uicontextmenu;
h_line.UIContextMenu = cmenu;

% menu items
uimenu(cmenu, 'Label', 'Disable', 'Callback', {@data_point_enable_disable, h_line, h_ax})
uimenu(cmenu, 'Label', 'Disable All', 'Callback', {@data_point_enable_disable, h_line, h_ax})