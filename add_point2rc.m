function add_point2rc(h_ax, table_row_num, magstim_val, mep_val)

h_line = line(h_ax, magstim_val, mep_val, ...
	'Marker', '.', 'MarkerSize', 40);
h_line.UserData.table_row_num = table_row_num;

drawnow

% make sure recruit curve window is in front, so context menu gets
% created in the correct figure
figure(h_ax.Parent.Number)

% context menu to disable/enable points
cmenu = uicontextmenu;
h_line.UIContextMenu = cmenu;

% menu items
hm = uimenu(cmenu, 'Label', 'Disable', 'Callback', {@data_point_enable_disable, h_line, h_ax});
uimenu(cmenu, 'Label', 'Disable All', 'Callback', {@data_point_enable_disable, h_line, h_ax})

% if the datapoint is disabled
if ~h_ax.UserData.Use(table_row_num)
	data_point_enable_disable(hm, [], h_line, h_ax)
end