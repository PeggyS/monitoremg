function save_computed_mep_info(~, ~, app)

% save data point table
dp_save_file = app.DatapointsCSVEditField.Value;
% if the current directory has '/data/' in it then change it
% '/analysis/' to save the output there
[save_loc, save_f, save_ext] = fileparts(dp_save_file);
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
datapoint_fname = fullfile(save_loc, [save_f save_ext]);
tbl_to_save = cell2table(app.h_uitable.Data, 'VariableNames', ...
			col_name_html_to_var_name(app.h_uitable.ColumnName));

% confirm that the subject in the save_loc is the same as the subject in the m_max file
confirm_subj_match = test_subject_match(save_loc, app.MMaxFileEditField.Value);
if ~confirm_subj_match
	subj_1 = regexp(save_loc, '([sc][\d]+\w+)', 'match');
	subj_1	= subj_1{1};
	subj_2 = regexp(app.MMaxFileEditField.Value, '([sc][\d]+\w+)', 'match');
	subj_2	= subj_2{1};

	msg = sprintf( 'Subject in emg data (%s) does not match the m-max subject (%s).', ...
		subj_1, subj_2);
	beep
	uialert(app.ReviewEMGRCUIFigure, msg, 'Subject Mismatch', 'Icon','error')
	return
end

% save the datapoint table
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


% save info about the analysis of the datapoint table
% save in the analysis folder with datapoints.csv file
save_file = strrep(datapoint_fname, 'datapoints.csv', 'datapoints_analysis_info.txt');

% filename (redundant, I guess)
app.dp_analysis_info.file_name = save_file;

% num std dev
app.dp_analysis_info.num_std_dev = str2double(app.h_num_std.String);

% if app.CheckBoxRc == true
	% rc plateau yes/no
	app.dp_analysis_info.rc_plateau = app.h_rc_plateau_checkbox.Value;
% end

% m-max from electrical stim for normalization
if app.MmaxEditField.Value == 1
	msg = '\fontsize{14}Electrical stimulation M-max value for normalization is 1. Are you want to save MEP info?';
	btn1 = 'Yes';
	btn2 = 'No';
	opts.Interpreter = 'tex';
	opts.Default = btn2;
	sel = questdlg(msg, 'Confirm Save', btn1, btn2, opts);
	if isempty(sel) || strcmp(sel, 'No')
		disp('Not saving MEP info.')
		return
	end
end
app.dp_analysis_info.e_stim_m_max_uV = app.MmaxEditField.Value;

% If analyzer initials are empty, change initials to the current user
if isempty(app.h_edit_mep_done_by.String)
	app.h_edit_mep_done_by.String = upper(app.user_initials);
	app.h_edit_mep_done_when.String = datestr(now, 'yyyy-mm-dd HH:MM:SS'); %#ok<DATST,TNOW1> 
end
app.dp_analysis_info.analyzed_by = app.h_edit_mep_done_by.String;
app.dp_analysis_info.analyzed_when = app.h_edit_mep_done_when.String;

app.dp_analysis_info.comments = strrep(app.h_mep_analysis_comments.String, ' : ', ' - ');

if app.h_chkbx_mep_verified_by.Value == true
	app.dp_analysis_info.verified_by = app.h_edit_mep_verified_by.String;
	app.dp_analysis_info.verified_when = app.h_edit_mep_verified_when.String;
end

% confirm saving
[confirm_saving, save_file] = confirm_savename(save_file);
if confirm_saving
	% write info to file
	write_fit_info(save_file, app.dp_analysis_info)
% 	fprintf('save_computed_mep_info: file\n %s\n with mep times = [%f %f]\n', save_file, ...
% 		app.mep_info.mep_beg_t, app.mep_info.mep_end_t)
end

return
end