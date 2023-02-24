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
[unq_tbl, unq_rows, tbl_ind] = unique(tbl(:, {'MagStim_Setting', 'BiStim_Setting', 'ISI_ms'}));

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
% make a way to examine the comments if there are any

% read in the info file
info = get_dp_analysis_info(datapoint_csv_filename);

return
end