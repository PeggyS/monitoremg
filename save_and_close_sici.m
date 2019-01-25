function save_and_close_sici(source, event, app)


if ~any(strcmp(properties(app), 'SaveLocationEditField')) 
	save_loc = pwd;
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
	fitinfo_fname = strrep(title_str, 'sici_datapoints.csv', 'sici_info.txt');
else
	datapoint_fname = [save_loc '/' fname_prefix title_str '_sici_datapoints.csv'];
	fitinfo_fname = [save_loc '/' fname_prefix title_str '_sici_info.txt'];
end

% % add norm or not norm to fit_info.txt
% if str2double(app.rc_fit_ui.edNormFactor.String) > 1
% 	fitinfo_fname = strrep(fitinfo_fname, 'info.txt', 'info_norm.txt');
% else
% 	fitinfo_fname = strrep(fitinfo_fname, 'info.txt', 'info_not_norm.txt');
% end

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
		case 'No'
			confirm_saving = false;
		case 'Cancel'
			return
	end
end	

if confirm_saving
	% save the data
	save_rc_table(app.sici_axes.UserData, datapoint_fname)
end % confirmed saving

if isfield(app.sici_info, 'muscle')
	if exist(sici_info_fname, 'file')
		[filename, pathname] = uiputfile('*.txt', 'Save fit info as');
		if isequal(filename,0) || isequal(pathname,0)
		   disp('User pressed cancel')
		else
			sici_info_fname = fullfile(pathname, filename);
		   disp(['User selected ', sici_info_fname])
		end
	end
	write_fit_info(sici_info_fname, app.sici_info)
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