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
% save it for the app (to look up comments)
app.datapoint_tbl = tbl;
% remove the unused rows from the tbl
tbl = tbl(tbl.Use == true, :);

% find unique combinations of magstim, bistim, and isi
[unq_tbl, ~, tbl_ind] = unique(tbl(:, {'MagStim_Setting', 'BiStim_Setting', 'ISI_ms', 'Effective_SO'}));

% each unique combo, compute the mean mep ampl and other stuff
for r_cnt = 1:height(unq_tbl)
	stim_tbl = tbl(tbl_ind==r_cnt, :);

	unq_tbl.num_samples(r_cnt) = height(stim_tbl);
	unq_tbl.num_mep(r_cnt) = sum(stim_tbl.Is_MEP);
	unq_tbl.mean_latency(r_cnt) = mean(stim_tbl.MEP_latency);
	if any(contains(stim_tbl.Properties.VariableNames, 'latency_adjusted'))
		unq_tbl.num_latency_manual_adjust(r_cnt) = sum(stim_tbl.latency_adjusted);
	else
		unq_tbl.num_latency_manual_adjust(r_cnt) = NaN;
	end
	unq_tbl.mean_end(r_cnt) = mean(stim_tbl.MEP_end);
	if any(contains(stim_tbl.Properties.VariableNames, 'end_adjusted'))
		unq_tbl.num_end_manual_adjust(r_cnt) = sum(stim_tbl.end_adjusted);
	else
		unq_tbl.num_end_manual_adjust(r_cnt) = NaN;
	end
	unq_tbl.mean_mep_ampl(r_cnt) = mean(stim_tbl.MEPAmpl_uVPp);
	if isnumeric(stim_tbl.comments)
		% comments are numeric, therefore there are no comments
		num_com = 0;
	else
		num_com = sum(~cellfun(@isempty, stim_tbl.comments));
	end
	unq_tbl.num_comments(r_cnt) = num_com;
end

unq_tbl = sortrows(unq_tbl, 'Effective_SO');

app.UITable_Unique_Stims.Data = unq_tbl;

% find the max amplitude and select that row in the table
[max_val, max_row] = max(unq_tbl.mean_mep_ampl);
% save the max mep info in the uitable user data
app.UITable_Unique_Stims.UserData.effective_stimulator_output = unq_tbl.Effective_SO(max_row);
app.UITable_Unique_Stims.UserData.num_samples = unq_tbl.num_mep(max_row);
app.UITable_Unique_Stims.UserData.num_meps = unq_tbl.num_mep(max_row);
app.UITable_Unique_Stims.UserData.mean_latency = unq_tbl.mean_latency(max_row);
app.UITable_Unique_Stims.UserData.num_latency_manual_adjust = unq_tbl.num_latency_manual_adjust(max_row);
app.UITable_Unique_Stims.UserData.mean_end = unq_tbl.mean_end(max_row);
app.UITable_Unique_Stims.UserData.num_end_manual_adjust = unq_tbl.num_end_manual_adjust(max_row);
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
% get(app.Image_rc)
img_file = strrep(datapoint_csv_filename, '_rc_datapoints.csv', '_p2p_fit_info_not_norm.png');
if exist(img_file, 'file')
	app.Image_rc.ImageSource = img_file;
else
	img_file = strrep(datapoint_csv_filename, '_rc_datapoints.csv', '_active_p2p_fit_info_not_norm.png');
	if exist(img_file, 'file')
		app.Image_rc.ImageSource = img_file;
	else
		img_file = strrep(datapoint_csv_filename, '_rc_datapoints.csv', '_p2p_fit_info_norm.png');
		if exist(img_file, 'file')
			app.Image_rc.ImageSource = img_file;
		else
			app.Image_rc.ImageSource = '';
		end
	end
end
	% read in the info file
info = get_dp_analysis_info(datapoint_csv_filename);

% put info into the mepmax info panel
app.NumSDEditField.Value = info.num_std_dev;
app.EStimMmaxEditField.Value = info.e_stim_m_max_uV;
app.AnalysisdateEditField.Value = info.analyzed_when;
app.AnalyzedbyEditField.Value = info.analyzed_by;
app.VerifydateEditField.Value = info.verified_when;
app.VerifiedbyEditField.Value = info.verified_by;
if isempty(info.rc_plateau)
	msg = sprintf('RC plateau value missing from %s.\n\nSetting to FALSE.', info.file_name);
	uialert(app.TMSInfotoDatabaseUIFigure, msg, 'RC Info Missing', 'Icon', 'warning')
	info.rc_plateau = 0;
end
app.RecruitmentCurvePlateauedCheckBox.Value = info.rc_plateau;
app.CommentsEditField.Value = info.comments;

% read in the rc fit info
rc_fname = strrep(datapoint_csv_filename, '_rc_datapoints.csv', '_p2p_fit_info_not_norm.txt');
% remove date at beginning of file name, if it is there
rc_fname = regexprep(rc_fname, '\d{8}_', '');
if contains(rc_fname, '15_')
	rc_fname = regexprep(rc_fname, '\d{2}_', ''); % and another 2 digits for s2706 followup inv gastroc
end
if contains(rc_fname, '20190311magstim') % remove this prefix for s2711 followup
	rc_fname = strrep(rc_fname, '20190311magstim_', '');
end
app.UITable_Unique_Stims.UserData.rc_info.not_norm = read_fit_info(rc_fname);
if ~isfield(app.UITable_Unique_Stims.UserData.rc_info.not_norm, 'mepMethod')
	msg = sprintf('RC p2p fit info not norm.txt file missing');
	uialert(app.TMSInfotoDatabaseUIFigure, msg, 'RC Info Missing', 'Icon', 'warning')
end

rc_fname = strrep(rc_fname, '_info_not_norm', '_info_norm');
app.UITable_Unique_Stims.UserData.rc_info.norm = read_fit_info(rc_fname);
if ~isfield(app.UITable_Unique_Stims.UserData.rc_info.not_norm, 'mepMethod')
	msg = sprintf('RC p2p fit info norm.txt file missing');
	uialert(app.TMSInfotoDatabaseUIFigure, msg, 'RC Info Missing', 'Icon', 'warning')
end


% is the data in the database?
is_mep_info_in_db(app)

return
end