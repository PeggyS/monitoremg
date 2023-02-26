function update_mep_info(selectedNode, app)

% datapoint file
datapoint_csv_filename = strrep(selectedNode.NodeData, '_analysis_info.txt', '.csv');
if ~exist(datapoint_csv_filename, 'file')
	beep
	disp(['There is no csv file: ' datapoint_csv_filename])
	reset_mep_info(app)
	return
end

% read in the datapoint table
% read first line, see if it contains 'magstim' or 'bistim'
fid = fopen(datapoint_csv_filename, 'rt');
first_line = fgetl(fid);
fclose(fid);
if contains(first_line, 'magstim') || contains(first_line, 'bistim')
% 	stimulator_setup = first_line;
	num_header_lines = 1;
else
	% no stimulator as first line
	beep
	disp(['The file ' datapoint_csv_filename ' does not contain the stimulator setup as the first line.'])
	disp('File is probably too old and needs to be reanalyzed in review_emg_rc.mlapp.')
	reset_mep_info(app)
	return
end
% table read in
tbl = readtable(datapoint_csv_filename, 'NumHeaderLines',num_header_lines);
tbl = tbl(tbl.Use == true, :);

% find unique combinations of magstim, bistim, and isi
[unq_tbl, ~, tbl_ind] = unique(tbl(:, {'MagStim_Setting', 'BiStim_Setting', 'ISI_ms', 'Effective_SO'}));

% each unique combo, compute the mean mep ampl and other stuff
for r_cnt = 1:height(unq_tbl)
	stim_tbl = tbl(tbl_ind==r_cnt, :);

	unq_tbl.num_samples(r_cnt) = height(stim_tbl);
	unq_tbl.num_mep(r_cnt) = sum(stim_tbl.Is_MEP);
	unq_tbl.mean_latency(r_cnt) = mean(stim_tbl.MEP_latency);
	unq_tbl.mean_end(r_cnt) = mean(stim_tbl.MEP_end);
	unq_tbl.mean_mep_ampl(r_cnt) = mean(stim_tbl.MEPAmpl_uVPp);
	if isnumeric(stim_tbl.comments)
		% comments are numeric, therefore there are no comments
		num_com = 0;
	else
		num_com = sum(~cellfun(@isempty, stim_tbl.comments));
	end
	unq_tbl.num_comments(r_cnt) = num_com;
end

app.UITable_Unique_Stims.Data = unq_tbl;

% find the max amplitude and select that row in the table
[max_val, max_row] = max(unq_tbl.mean_mep_ampl);
% save the max mep info in the uitable user data
app.UITable_Unique_Stims.UserData.effective_stimulator_output = unq_tbl.Effective_SO(max_row);
app.UITable_Unique_Stims.UserData.num_samples = unq_tbl.num_mep(max_row);
app.UITable_Unique_Stims.UserData.num_meps = unq_tbl.num_mep(max_row);
app.UITable_Unique_Stims.UserData.mean_latency = unq_tbl.mean_latency(max_row);
app.UITable_Unique_Stims.UserData.mean_end = unq_tbl.mean_end(max_row);
app.UITable_Unique_Stims.UserData.mep_max = max_val;
app.UITable_Unique_Stims.UserData.num_comments = unq_tbl.num_comments(max_row);

% make sure the max row is visible
scroll(app.UITable_Unique_Stims, 'row', max_row)
styl = uistyle;
% highlight the row. color it depending upon if the latency values
% were computed
if abs(unq_tbl.mean_latency(max_row) - 10) < eps % 10 is the default latency value
	styl.BackgroundColor = '#c94309';
else
	styl.BackgroundColor = '#dddd00';
end
removeStyle(app.UITable_Unique_Stims)
addStyle(app.UITable_Unique_Stims, styl, 'row', max_row)

% is the mep max at the highest stimulator output?
if max_row < height(unq_tbl)
	app.MEPmaxatMaxSOCheckBox.Value = 0;
else
	app.MEPmaxatMaxSOCheckBox.Value = 1;
end

% add the rc curve image
get(app.Image_rc)
img_file = strrep(datapoint_csv_filename, '_rc_datapoints.csv', '_p2p_fit_info_norm.png');
if exist(img_file, 'file')
	app.Image_rc.ImageSource = img_file;
else
	img_file = strrep(datapoint_csv_filename, '_rc_datapoints.csv', '_p2p_fit_info_not_norm.png');
	if exist(img_file, 'file')
		app.Image_rc.ImageSource = img_file;
	else
		app.Image_rc.ImageSource = '';
	end
end

% make a way to examine the comments if there are any - FIXME

% read in the info file
info = get_dp_analysis_info(datapoint_csv_filename);

% put info into the mepmax info panel
app.NumSDEditField.Value = info.num_std_dev;
app.EStimMmaxEditField.Value = info.e_stim_m_max_uV;
app.AnalysisdateEditField.Value = info.analyzed_when;
app.AnalyzedbyEditField.Value = info.analyzed_by;
app.VerifydateEditField.Value = info.verified_when;
app.VerifiedbyEditField.Value = info.verified_by;
app.RecruitmentCurvePlateauedCheckBox.Value = info.rc_plateau;
app.CommentsEditField.Value = info.comments;

% is the data in the database?
subject = app.SubjectEditField_muscP.Value;
session = app.SessionEditField_muscP.Value;
side_muscle = app.MuscleEditField_muscP.Value;
split_cell = strsplit(side_muscle, '_');
side = split_cell{1};
muscle = split_cell{2};

db_info = get_mep_max_latency_data_from_db(app, subject, session, side, muscle);
if ~isempty(db_info)
	app.InDatabaseCheckBox.Value = true;
	app.dbLastupdatedEditField.Value = db_info.last_update;
	% does the database info match what's shown here?
	match = true;
	if db_info.effective_stimulator_output ~= app.UITable_Unique_Stims.UserData.effective_stimulator_output || ...
		db_info.is_eff_so_max_stim ~= app.MEPmaxatMaxSOCheckBox.Value || ...
		db_info.num_samples ~= app.UITable_Unique_Stims.UserData.num_samples || ...
		db_info.num_meps ~= app.UITable_Unique_Stims.UserData.num_meps || ...
		db_info.mep_mean_latency ~= app.UITable_Unique_Stims.UserData.mean_latency || ...
		db_info.mep_mean_end_time ~= app.UITable_Unique_Stims.UserData.mean_end || ...
		db_info.mep_mean_amplitude ~= app.UITable_Unique_Stims.UserData.mep_max || ...
		db_info.num_samples_with_comments ~= app.UITable_Unique_Stims.UserData.num_comments || ...
		db_info.num_sd ~= app.NumSDEditField.Value || ...
		db_info.e_stim_m_max ~= app.EStimMmaxEditField.Value || ...
		db_info.did_rc_plateau ~= app.RecruitmentCurvePlateauedCheckBox.Value || ...
		contains(db_info.analyzed_by, app.AnalyzedbyEditField.Value) || ...
		contains(db_info.analyzed_when, app.AnalysisdateEditField.Value) || ...
		contains(db_info.verified_by, app.VerifiedbyEditField.Value) || ...
		contains(db_info.verfied_when, app.VerifydateEditField.Value) || ...
		contains(db_info.comments, app.CommentsEditField.Value) 
		match = false;
	end
	if match == true
		app.DatabaseinfomatchesCheckBox.Value = true;
	else
		app.DatabaseinfomatchesCheckBox.Value = false;
	end
else
	app.InDatabaseCheckBox.Value = false;
	app.dbLastupdatedEditField.Value = '';
	app.DatabaseinfomatchesCheckBox.Value = false;
end % info in the database

return
end