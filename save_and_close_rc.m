function save_and_close_rc(source, event, app)

if ~isfield(app, 'SaveLocationEditField') % field only present in run_emg.mlapp (online app)
	% this section runs for review_emg_rc.mlapp
	save_loc = pwd;
	fname_prefix = '';
else
	if isempty(app.SaveLocationEditField.Value)
		app.SaveLocationEditField.Value = pwd;
		save_loc = pwd;
		fname_prefix = app.EditFieldFilenameprefix.Value;
	end
end

% determine base filename for saving datapoints.csv & fitinfo.txt
title_str = strrep(app.rc_axes.Title.String, ' ', '_');
if contains(title_str, '.csv') % it's a file read in, no need to add prefix
	datapoint_fname = title_str;
	fitinfo_fname = strrep(title_str, 'rc_datapoints.csv', 'fit_info_not_norm.txt');
else
	datapoint_fname = [save_loc '/' fname_prefix title_str '_rc_datapoints.csv'];
	fitinfo_fname = [save_loc '/' fname_prefix title_str '_fit_info_not_norm.txt'];
end
% if norm value > 1, change not_norm to norm in fitinfo_fname
if str2double(app.rc_fit_ui.edNormFactor.String) > 1
	fitinfo_fname = strrep(fitinfo_fname, '_not_norm', '_norm');
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
		[filename, pathname] = uiputfile('*.txt', 'Save fit info as');
		if isequal(filename,0) || isequal(pathname,0)
		   disp('User pressed cancel')
		else
			fitinfo_fname = fullfile(pathname, filename);
		   disp(['User selected ', fitinfo_fname])
		end
	end
	write_fit_info(fitinfo_fname, app.rc_fit_info)
end	


if strcmp(source.Tag, 'pushbutton')  % don't delete if the save pushbutton called this function
	return
end

% delete the figure
delete(source)

% change checkbox
if isfield(app, 'CheckBoxRecruitCurve')
	app.CheckBoxRecruitCurve.Value = 0;
end

return