function add_point2sici(app, table_row_num, mep_val)

h_ax = app.sici_axes;
if strcmp(h_ax.UserData.Stim_Type(table_row_num), '?') 
	stim_type = app.sici_popmenu.String{app.sici_popmenu.Value};
	h_ax.UserData.Stim_Type(table_row_num) = {stim_type};
else
	stim_type = h_ax.UserData.Stim_Type{table_row_num};
end


switch stim_type
	case 'Test Stim'
		marker = '.';
		markersize = 40;
		x_value = 1;
		info_var = 'ts';
	case 'SICI'
		marker = '.';
		markersize = 40;
		x_value = 2;
		info_var = 'sici';
	case 'ICF'
% 		marker = 's';
% 		markersize = 10;
		marker = '.';
		markersize = 40;
		x_value = 3;
		info_var = 'icf';	
	case 'LICI'
		marker = '.';
		markersize = 40;
		x_value = 4;
		info_var = 'lici';
end

h_line = line(h_ax, x_value, mep_val, 'Marker', marker, 'MarkerSize', markersize);
h_line.UserData.table_row_num = table_row_num;

pause(0)

% make sure sici window is in front, so context menu gets
% created in the correct figure
figure(h_ax.Parent.Number)

% context menu to disable/enable points
cmenu = uicontextmenu;
h_line.UIContextMenu = cmenu;

% menu items
hm = uimenu(cmenu, 'Label', 'Disable', 'Callback', {@data_point_menu_callback, h_line, h_ax});


% change size/color for the most recent data point added
persistent h_prev_line
h_mainwin = findobj('Name', 'EMG Display & RC');
if isgraphics(h_mainwin)	% only do this if running in real time 
	
	if h_ax.UserData.MonitorEMGval(table_row_num) > h_ax.UserData.GoalEMGmax(table_row_num)
		h_line.Color = [170 100 245]/255;
	elseif h_ax.UserData.MonitorEMGval(table_row_num) < h_ax.UserData.GoalEMGmin(table_row_num)
		h_line.Color = [255 193 59]/255;
	else
		h_line.Color = [0 0.8 0];
	end

	h_line.MarkerFaceColor = h_line.Color;
	h_line.MarkerSize = markersize*1.3;
	
	% set prev_line to default values
	if ~isempty(h_prev_line) && isgraphics(h_prev_line)
		h_prev_line.Color = [0    0.4470    0.7410];
		h_prev_line.MarkerSize = h_prev_line.MarkerSize/1.3;
		h_prev_line.MarkerFaceColor = h_prev_line.Color;
% 		if h_prev_line.Marker == '.'
% 			h_prev_line.MarkerSize = 40;
% 		else
% 			h_prev_line.MarkerSize = 20;
% 		end
	end

	h_prev_line = h_line; 
end

if isfield(app.sici_ui, 'data_lines')
	app.sici_ui.data_lines = [app.sici_ui.data_lines h_line];
else
	app.sici_ui.data_lines = h_line;
end

% if the datapoint is disabled
if ~h_ax.UserData.Use(table_row_num)
	data_point_menu_callback(hm, [], h_line, h_ax)
end

update_sici_mean_sc_ci_lines(app, stim_type, info_var)

