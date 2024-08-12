function update_sici_info(selectedNode, app)

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
[unq_tbl, ~, tbl_ind] = unique(tbl(:, {'MagStim_Setting', 'BiStim_Setting', 'ISI_ms', 'Stim_Type'}));

more_info_tbl = table();
more_info_tbl.stim_type = unq_tbl.Stim_Type;

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

	more_info_tbl.sd_latency(r_cnt) = std(stim_tbl.MEP_latency);
	more_info_tbl.sd_end(r_cnt) = std(stim_tbl.MEP_end);
	more_info_tbl.sd_mep_ampl(r_cnt) = std(stim_tbl.MEPAmpl_uVPp);
	ci = confidence_intervals(stim_tbl.MEPAmpl_uVPp, 98);
	more_info_tbl.ci1_mep_ampl(r_cnt) = ci(1);
	more_info_tbl.ci2_mep_ampl(r_cnt) = ci(2);

end

app.UITable_Unique_Stims_sici.Data = unq_tbl;


% save the more sici info in the uitable user data
app.UITable_Unique_Stims_sici.UserData.more_info_tbl = more_info_tbl;


% add the sici curve image
% get(app.Image_rc)
img_file = strrep(datapoint_csv_filename, '_sici_datapoints.csv', '_p2p_sici_info_not_norm.png');
if exist(img_file, 'file')
	app.Image_sici.ImageSource = img_file;
else
	img_file = strrep(datapoint_csv_filename, '_sici_datapoints.csv', '_p2p_sici_info_norm.png');
	if exist(img_file, 'file')
		app.Image_sici.ImageSource = img_file;
	else
		app.Image_sici.ImageSource = '';
	end
end


% read in the info file
info = get_dp_analysis_info(datapoint_csv_filename);

% put info into the sici info panel
app.NumSDEditField_sici.Value = info.num_std_dev;
app.AnalysisdateEditField_sici.Value = info.analyzed_when;
app.AnalyzedbyEditField_sici.Value = info.analyzed_by;
app.VerifydateEditField_sici.Value = info.verified_when;
app.VerifiedbyEditField_sici.Value = info.verified_by;
app.CommentsEditField_sici.Value = info.comments;

% is the data in the database?
is_sici_info_in_db(app)


return
end