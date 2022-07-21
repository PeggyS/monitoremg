function pushbutton_compute_mep_beg(src, evt, app)  %#ok<INUSL>

disp('callback function not working yet')

pre_stim_val = app.h_pre_stim_emg_line.YData(1);

% use the mean emg line
h_mean_emg_line = findobj(app.h_disp_emg_axes, 'Tag', 'mean_mep_line');

abs_mean_emg = abs(h_mean_emg_line.YData);
[~, min_emg_ind] = min(h_mean_emg_line.YData, [], 'omitnan');
[~, max_emg_ind] = max(h_mean_emg_line.YData, [], 'omitnan');

% min index is the first extreme datapoint
min_ind = min([min_emg_ind max_emg_ind]);

% search for the last time before the min_ind that is below the pre_stim_val
search_ind = find(abs_mean_emg(1:min_ind) <= pre_stim_val, 1, 'last');
if abs_mean_emg(search_ind) == pre_stim_val
	mep_begin = h_mean_emg_line.XData(search_ind);
else
	% the next point will be above threshold
	threshold_ind = search_ind+1;

	t_before_thresh = h_mean_emg_line.XData(search_ind);
	t_after_thresh = h_mean_emg_line.XData(threshold_ind);
	val_before_thresh = abs_mean_emg(search_ind);
	val_after_thresh = abs_mean_emg(threshold_ind);
	% linear interpolate to find the time that crosses threshold
	mep_begin = interp1([val_before_thresh val_after_thresh], [t_before_thresh t_after_thresh], pre_stim_val);
	fprintf('auto computed mep begin t = %f\n', mep_begin)
end
% change the mep start line
app.h_t_min_line.XData = [mep_begin mep_begin];


% update the edit box and uitable with new data since the mep_beg_time
% changed
mep_line_drag_endfcn(app.h_t_min_line) 


% save info used to compute mep_begin
% save in the analysis folder with datapoints.csv file
save_file = strrep(app.DatapointsCSVEditField.Value, 'datapoints.csv', 'mep_auto_compute_info.txt');
% if the current directory has '/data/' in it then change it
% '/analysis/' to save the output there
[save_loc, save_f, save_ext] = fileparts(save_file);
if contains(save_loc, [filesep 'data' filesep], 'IgnoreCase', true)
	save_loc = strrep(lower(save_loc), [filesep 'data' filesep], [filesep 'analysis' filesep]);
	% ask to create the folder if it doesn't exist
	if ~exist(save_loc, 'dir')
		ButtonName = questdlg(['Create new directory: ' save_loc ' ?'], ...
			'Create new directory', ...
			'Yes', 'No', 'Yes');
		if strcmp(ButtonName, 'Yes')
			[success, msg, msg_id] = mkdir(save_loc); %#ok<ASGLU>
		else
			disp('Choose where to save output')
			save_loc = uigetdir();
			% 				while save_loc==0
			% 					disp('Must choose a folder to save output.')
			% 					save_loc = uigetdir();
			% 				end
		end
	end
end
save_file = fullfile(save_loc, [save_f save_ext]);
info.mep_begin_time = mep_begin;
info.epochs_used = all_selected;
write_fit_info(save_file, info)
fprintf('saved new mep auto compute file\n %s\n with mep begin time = %f\n', save_file, mep_begin)

return
end % pushbutton_compute_mep_beg