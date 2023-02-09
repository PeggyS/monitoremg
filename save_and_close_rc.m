function save_and_close_rc(source, event, app) %#ok<INUSL> 
% cur_dir = pwd;

if ~any(strcmp(properties(app), 'SaveLocationEditField'))
	% review_emg_rc app has no property for save location, use file path
	% location
	try
		[pname, ~, ~] = fileparts(app.EMGDataTxtEditField.Value);
	catch
		delete(source)
		return
	end
	save_loc = pname;
	% if the current directory has '/data/' in it then change it
	% '/analysis/' to save the output there
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
	fname_prefix = '';
	tbl_to_save = cell2table(app.h_uitable.Data, 'VariableNames', ...
			col_name_html_to_var_name(app.h_uitable.ColumnName));
else
	if isempty(app.SaveLocationEditField.Value)
		app.SaveLocationEditField.Value = pwd;
		save_loc = pwd;
	else
		save_loc = app.SaveLocationEditField.Value;
	end
	fname_prefix = app.EditFieldFilenameprefix.Value;
	tbl_to_save = app.rc_axes.UserData;
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
	datapoint_fname = [save_loc filesep fname_prefix title_str '_rc_datapoints.csv'];
	if isfield(app.rc_fit_info, 'mepMethod')
		fitinfo_fname = [save_loc filesep fname_prefix title_str '_' app.rc_fit_info.mepMethod '_fit_info.txt'];
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

[confirm_saving, datapoint_fname] = confirm_savename(datapoint_fname);
if confirm_saving
	% save the data
	try
		save_rc_table(tbl_to_save, datapoint_fname)
	catch ME
		disp('did not save rc_datapoints')
		disp(ME)
	end
end % confirmed saving


if isfield(app.rc_fit_info, 'mepMethod')
	[confirm_saving, fitinfo_fname] = confirm_savename(fitinfo_fname);
	if confirm_saving
		% add analyzed by and when
		if isprop(app, 'ReviewEMGRCUIFigure') % if in review_emg_rc app
			app.rc_fit_info.analyzed_by = upper(app.user_initials);
			app.AnalyzedbyEditField.Value = upper(app.user_initials);
			app.rc_fit_info.analyzed_when = datestr(now, 'yyyy-mm-dd HH:MM:SS');
			app.AnalyzedWhenEditField.Value = app.rc_fit_info.analyzed_when;
			app.rc_fit_info.comments = app.h_mep_analysis_comments.String;
		end
		try
			write_fit_info(fitinfo_fname, app.rc_fit_info)
		catch ME
			disp('did not save fit_info')
			disp(ME)
		end
		% print the figure
		try
			print_rc([], [], app)
		catch ME
			disp('did not print the figure')
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
if any(strcmp(properties(app), 'CheckBoxRecruitCurve'))
	app.CheckBoxRecruitCurve.Value = 0;
end

return