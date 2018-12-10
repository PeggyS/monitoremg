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


% change size/color for the most recent data point added
persistent h_prev_line
h_magspy = findobj('Name', 'Magstim Power');
if ~isgraphics(h_magspy)	% only do this if running in real time (magspy is running)
	
	if h_ax.UserData.MonitorEMGval(table_row_num) > h_ax.UserData.GoalEMGmax(table_row_num)
		h_line.Color = [170 100 245]/255;
	elseif h_ax.UserData.MonitorEMGval(table_row_num) < h_ax.UserData.GoalEMGmin(table_row_num)
		h_line.Color = [255 193 59]/255;
	else
		h_line.Color = [0 0.8 0];
	end

	h_line.MarkerSize = 50;
	
	% set prev_line to default values
	if ~isempty(h_prev_line)
		h_prev_line.Color = [0    0.4470    0.7410];
		h_prev_line.MarkerSize = 40;
	end

	h_prev_line = h_line; 
end

% if the datapoint is disabled
if ~h_ax.UserData.Use(table_row_num)
	data_point_enable_disable(hm, [], h_line, h_ax)
end
