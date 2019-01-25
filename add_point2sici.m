function add_point2sici(app, table_row_num, magstim_val, mep_val)

h_ax = app.sici_axes;
stim_type = app.sici_popmenu.String{app.sici_popmenu.Value};
h_ax.UserData.Sici_or_icf_or_ts(table_row_num) = {stim_type};


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
end

h_line = line(h_ax, x_value, mep_val, 'Marker', marker, 'MarkerSize', markersize);
h_line.UserData.table_row_num = table_row_num;

drawnow

% make sure sici window is in front, so context menu gets
% created in the correct figure
figure(h_ax.Parent.Number)

% context menu to disable/enable points
cmenu = uicontextmenu;
h_line.UIContextMenu = cmenu;

% menu items
hm = uimenu(cmenu, 'Label', 'Disable', 'Callback', {@data_point_enable_disable, h_line, h_ax});
%uimenu(cmenu, 'Label', 'Disable All', 'Callback', {@data_point_enable_disable, h_line, h_ax})


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

% if the datapoint is disabled
if ~h_ax.UserData.Use(table_row_num)
	data_point_enable_disable(hm, [], h_line, h_ax)
end

% once there are 5 points, draw the mean & std dev of the data points
tbl_stim_type = h_ax.UserData(strcmp(h_ax.UserData.Sici_or_icf_or_ts, stim_type), :);
tbl_use = tbl_stim_type(tbl_stim_type.Use,:);
n_var = [info_var '_n'];
app.sici_info.(n_var).String = num2str(height(tbl_use));
if height(tbl_use) > 5
	mean_var = [info_var '_mean' ];
	sd_var = [info_var '_sd'];	
	app.sici_info.(mean_var).String = num2str(mean(tbl_use.MEPAmpl_uVPp));
	app.sici_info.(sd_var).String = num2str(std(tbl_use.MEPAmpl_uVPp));
end

