function save_and_close_sici(source, event, app)


if ~any(strcmp(properties(app), 'SaveLocationEditField')) 
	[pname, ~, ~] = fileparts(app.EMGDataTxtEditField.Value);
	save_loc = pname;
	% if the current directory has '/data/' in it then change it
	% '/analysis/' to save the output there
	if contains(save_loc, '/data/', 'IgnoreCase', true)
		save_loc = strrep(lower(save_loc), '/data/', '/analysis/');
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
title_str = strrep(app.sici_axes.Title.String, ' ', '_');
if contains(title_str, '.csv') % it's a file read in, no need to add prefix
	datapoint_fname = title_str;
	sici_info_fname = strrep(title_str, 'sici_datapoints.csv', 'sici_info.txt');
else
	datapoint_fname = [save_loc '/' fname_prefix title_str '_sici_datapoints.csv'];
	sici_info_fname = [save_loc '/' fname_prefix title_str '_sici_info.txt'];
end

% % add norm or not norm to fit_info.txt
% if str2double(app.rc_fit_ui.edNormFactor.String) > 1
% 	fitinfo_fname = strrep(fitinfo_fname, 'info.txt', 'info_norm.txt');
% else
% 	fitinfo_fname = strrep(fitinfo_fname, 'info.txt', 'info_not_norm.txt');
% end

[confirm_saving, datapoint_fname] = confirm_savename(datapoint_fname);

% confirm_saving = true;

% if exist(datapoint_fname, 'file')
% 	suffix_str = datestr(now, '_yyyymmdd_HHMMSS');
% 	q_str = ['\fontsize{14} ' strrep(datapoint_fname, '_', '\_') ...
% 		' already exists. Do you want to save a new version with the suffix ' ...
% 		strrep(suffix_str, '_', '\_') '?' ];

% 	opts.Interpreter = 'tex';
% 	opts.Default = 'Yes';
% 	ans_button = questdlg(q_str, 'Save File', opts);
	
% 	switch ans_button
% 		case 'Yes'
% 			datapoint_fname = strrep(datapoint_fname, '.csv', [suffix_str '.csv']);
% 		case 'No'
% 			confirm_saving = false;
% 		case 'Cancel'
% 			return
% 	end
% end	

if confirm_saving
	% save the data
	try
		save_rc_table(app.sici_axes.UserData, datapoint_fname)
	catch ME
		disp('did not save rc_datapoints')
		disp(ME)
	end
end % confirmed saving

if isfield(app.sici_info, 'ts_n')
	% if exist(sici_info_fname, 'file')
	% 	[filename, pathname] = uiputfile('*.txt', 'Save fit info as');
	% 	if isequal(filename,0) || isequal(pathname,0)
	% 	   disp('User pressed cancel')
	% 	else
	% 		sici_info_fname = fullfile(pathname, filename);
	% 	   disp(['User selected ', sici_info_fname])
	% 	end
	% end
	[confirm_saving, sici_info_fname] = confirm_savename(sici_info_fname);

	% get the TS & CS values
	app.sici_info.ts_value = str2double(app.sici_ui.ts.String);
	app.sici_info.cs_value = str2double(app.sici_ui.cs.String);
	if confirm_saving
		try
			write_fit_info(sici_info_fname, app.sici_info)
			catch ME
			disp('did not save fit_info')
			disp(ME)
		end
	end
end	


if strcmp(source.Tag, 'pushbutton')  % don't delete if the save pushbutton called this function
	return
end

% delete the figure
delete(source)

% change checkbox
if any(strcmp(properties(app), 'CheckBoxSici'))
	app.CheckBoxSici.Value = 0;
end


return