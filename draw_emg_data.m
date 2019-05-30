function [mep_val, pre_stim_val] = draw_emg_data(app, emg_data, monitor_emg_val, goal_min, goal_max)

% display the data
app.h_emg_line.YData = emg_data;

% adjust y limits
app.h_disp_emg_axes.YLim = [min(emg_data) max(emg_data)];

% compute the pre-stim emg
left_time = app.preEmgMinEditField.Value; % 100 ms prior to stim (+ 1 ms to allow for stim artifact)
right_time = app.preEmgMaxEditField.Value; 
pre_stim_data = app.h_emg_line.YData(app.h_emg_line.XData>=left_time ...
	& app.h_emg_line.XData<right_time);
if app.MeanRectifiedValueButton.Value
	pre_stim_val = mean(abs(pre_stim_data) - mean(pre_stim_data));
else % using max peak to peak value
	pre_stim_val = max(pre_stim_data) - min(pre_stim_data);
end
set(app.pre_emg_text, 'String', [num2str(monitor_emg_val) ' (' num2str(round(pre_stim_val)) ')'])
% change the color depending on the proximity to the goal
if ~isempty(monitor_emg_val) && ~isempty(goal_min) && ~isempty(goal_max)
	if monitor_emg_val >= goal_min && ...
			monitor_emg_val <= goal_max  % in the green
		set(app.pre_emg_text, 'ForegroundColor', [20 224 20]/255)
	elseif monitor_emg_val < goal_min % below
		set(app.pre_emg_text, 'ForegroundColor', [255 153 0]/255)
	else % above
		set(app.pre_emg_text, 'ForegroundColor', [209 36 36]/255)
	end
else
	% colr = blue
	set(app.pre_emg_text, 'ForegroundColor', 'b')
end 

% get mep value 
t_emg = app.h_emg_line.XData;
t_mep_min = app.h_t_min_line.XData(1);
t_mep_max = app.h_t_max_line.XData(1);
mep_seg = emg_data(t_emg>t_mep_min & t_emg<t_mep_max);

mep_val = max(mep_seg) - min(mep_seg);

if app.SubtractPreEMGppButton.Value % subtract the pre stim emg
	mep_val = mep_val - pre_stim_val;
end


set(app.mep_value_text, 'String', num2str(round(mep_val)))
if mep_val >= app.MEPThresholdEditField.Value
	set(app.mep_value_text, 'ForegroundColor', 'r')
else
	set(app.mep_value_text, 'ForegroundColor', 'b')
end

drawnow