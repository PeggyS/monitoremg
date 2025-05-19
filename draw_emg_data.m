function [mep_val, pre_stim_val] = draw_emg_data(app, emg_data, monitor_emg_val, ...
								goal_min, goal_max, stim_info)

% display the data
% shift the data if isi > 0
if ~isempty(stim_info.isi_ms) && stim_info.isi_ms > 0 && stim_info.bistim_val > 0
	isi_shift_pts = round(app.params.sampFreq * stim_info.isi_ms / 1000);
else
	isi_shift_pts = 0;
end
tmp_data = emg_data;
app.h_emg_line.YData = [tmp_data(isi_shift_pts+1:end) nan(1,isi_shift_pts)];


% adjust y limits
min_y = min(emg_data);
max_y = max(emg_data);
if max_y-min_y > eps
	app.h_disp_emg_axes.YLim = [min_y max_y];
end

% compute the pre-stim emg
% pre_stim_val = compute_pre_stim_emg_value(app, emg_data);
pre_stim_val = compute_pre_stim_emg_value(app, app.h_emg_line);
% update std line
std_val = compute_pre_stim_emg_std_value(app, app.h_emg_line) * 3;
app.h_pre_stim_emg_pos_std_line.YData = [std_val std_val];
app.h_pre_stim_emg_neg_std_line.YData = [-std_val -std_val];


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
mep_seg = app.h_emg_line.YData(t_emg>t_mep_min & t_emg<t_mep_max);

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