function save_and_close_rc(source, event, app)
cur_dir = pwd;

if ~any(strcmp(properties(app), 'SaveLocationEditField'))
	% review_emg_rc app has no property for save location
	save_loc = cur_dir;
	% if the current directory has '/data/' in it then change it
	% '/analysis/' to save the output there
	if contains(save_loc, '/data/', 'IgnoreCase', true)
		save_loc = strrep(save_loc, '/data/', '/analysis/');
		% ask to create the folder if it doesn't exist
		if ~exist(save_loc, 'dir')
			ButtonName = questdlg(['Create new directory: ' save_loc ' ?'], ...
                         'Create new directory', ...
                         'Yes', 'No', 'Yes');
			if strcmp(ButtonName, 'Yes')
				[success, msg, msg_id] = mkdir(save_loc);
			else
				disp('Choose where to save output')
				save_loc = uigetdir();
			end
		end
	end
	fname_prefix = '';
else
	if isempty(app.SaveLocationEditField.Value)
		app.SaveLocationEditField.Value = pwd;
		save_loc = pwd;
	else
		save_loc = app.SaveLocationEditField.Value;
	end
	fname_prefix = app.EditFieldFilenameprefix.Value;
end

% determine base filename for saving datapoints.csv & fitinfo.txt
title_str = strrep(app.rc_axes.Title.String, ' ', '_');
if contains(title_str, '.csv') % it's a file read in, no need to add prefix
	datapoint_fname = title_str;
	if isfield(app.rc_fit_info, 'mepMethod')
		fitinfo_fname = strrep(title_str, 'rc_datapoints.csv', [app.rc_fit_info.mepMethod 'fit_info.txt']);
	else
		fitinfo_fname = 'fit.txt';
	end
else
	datapoint_fname = [save_loc '/' fname_prefix title_str '_rc_datapoints.csv'];
	if isfield(app.rc_fit_info, 'mepMethod')
		fitinfo_fname = [save_loc '/' fname_prefix title_str '_' app.rc_fit_info.mepMethod '_fit_info.txt'];
	else
		fitinfo_fname = 'fit.txt';
	end
end

% add norm or not norm to fit_info.txt
if str2double(app.rc_fit_ui.edNormFactor.String) > 1
	fitinfo_fname = strrep(fitinfo_fname, 'info.txt', 'info_norm.txt');
else
	fitinfo_fname = strrep(fitinfo_fname, 'info.txt', 'info_not_norm.txt');
end

confirm_saving = true;

if exist(datapoint_fname, 'file')
	suffix_str = datestr(now, '_yyyymmdd_HHMMSS');
	q_str = ['\fontsize{14} ' strrep(datapoint_fname, '_', '\_') ...
		' already exists. Do you want to save a new version with the suffix ' ...
		strrep(suffix_str, '_', '\_') '?' ];

	opts.Interpreter = 'tex';
	opts.Default = 'Yes';
	ans_button = questdlg(q_str, 'Save File', opts);
	
	switch ans_button
		case 'Yes'
			datapoint_fname = strrep(datapoint_fname, '.csv', [suffix_str '.csv']);
% 			fitinfo_fname = strrep(fitinfo_fname, '.txt', [suffix_str '.txt']);
		case 'No'
			confirm_saving = false;
		case 'Cancel'
			return
	end
end	

if confirm_saving
	% save the data
	save_rc_table(app.rc_axes.UserData, datapoint_fname)
end % confirmed saving


if isfield(app.rc_fit_info, 'mepMethod')
	if exist(fitinfo_fname, 'file')
		disp('Save fit info as...')
		cd(save_loc)
		[filename, pathname] = uiputfile('*.txt', 'Save fit info as');
		if isequal(filename,0) || isequal(pathname,0)
		   disp('User pressed cancel')
		else
			fitinfo_fname = fullfile(pathname, filename);
		   disp(['User selected ', fitinfo_fname])
		end
		cd(cur_dir)
	end
	write_fit_info(fitinfo_fname, app.rc_fit_info)
end	


if strcmp(source.Tag, 'pushbutton')  % don't delete if the save pushbutton called this function
	return
end

% delete the figure
delete(source)

% change checkbox
if any(strcmp(properties(app), 'CheckBoxRecruitCurve'))
	app.CheckBoxRecruitCurve.Value = 0;
end

return