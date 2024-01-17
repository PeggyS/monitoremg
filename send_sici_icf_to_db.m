function send_sici_icf_to_db(app)

% open connection to database
dbparams = get_db_login_params(app.db_str);

% see if this data is already in the database
subject = app.SubjectEditField_muscP.Value;
session = app.SessionEditField_muscP.Value;
side_muscle = app.MuscleEditField_muscP.Value;

split_cell = strsplit(side_muscle, '_');
side = split_cell{1};
muscle = split_cell{2};

db_tbl = get_sici_icf_data_from_db(app, subject, session, side, muscle);
if isempty(db_tbl)
	% not there, need to add the data
	add_or_update = 'add';
else
	% there is something there, need to update the data
	add_or_update = 'update';
end


% get the data to send to database
% columns in the database
% id
% subject
% session
% side
% muscle
% stim_type
% num_samples
% num_meps
% mep_latency_mean
% mep_latency_sd
% num_mep_latencies_manually_adjusted
% mep_end_time_mean
% mep_end_time_sd
% num_mep_end_times_manually_adjusted
% mep_amplitude_mean
% mep_amplitude_sd
% mep_ampl_98pct_ci_1
% mep_ampl_98pct_ci_2
% num_samples_with_comments
% num_sd
% analyzed_by
% analyzed_when
% verified_by
% verfied_when
% comments



num_sd = app.NumSDEditField_sici.Value;
analyzed_by = app.AnalyzedbyEditField_sici.Value;
analyzed_when = app.AnalysisdateEditField_sici.Value;
verified_by = app.VerifiedbyEditField_sici.Value;
verified_when = app.VerifydateEditField_sici.Value;
comments = app.CommentsEditField_sici.Value;

% make sure verified when looks like a datetime to the database
if isempty(verified_when)
	verified_when = '2000-01-01 00:00:00';
end

try
	conn = dbConnect(dbparams.dbname, dbparams.user, dbparams.password, dbparams.serveraddr);
catch ME
	disp(ME)
	warning('could not connect to database')
	return
end

% each stim_type 
for r_cnt = 1:height(app.UITable_Unique_Stims_sici.Data)
	magstim_setting = app.UITable_Unique_Stims_sici.Data.MagStim_Setting(r_cnt);
	bistim_setting = app.UITable_Unique_Stims_sici.Data.BiStim_Setting(r_cnt);
	isi_ms = app.UITable_Unique_Stims_sici.Data.ISI_ms(r_cnt);
	stim_type = app.UITable_Unique_Stims_sici.Data.Stim_Type{r_cnt};
	num_samples = app.UITable_Unique_Stims_sici.Data.num_samples(r_cnt);
	num_meps = app.UITable_Unique_Stims_sici.Data.num_mep(r_cnt);
	mep_mean_latency = app.UITable_Unique_Stims_sici.Data.mean_latency(r_cnt);
	num_mep_latencies_manually_adjusted = app.UITable_Unique_Stims_sici.Data.num_latency_manual_adjust(r_cnt);
	mep_mean_end_time = app.UITable_Unique_Stims_sici.Data.mean_end(r_cnt);
	num_mep_end_times_manually_adjusted = app.UITable_Unique_Stims_sici.Data.num_end_manual_adjust(r_cnt);
	mep_mean_amplitude = app.UITable_Unique_Stims_sici.Data.mean_mep_ampl(r_cnt);
	num_samples_with_comments = app.UITable_Unique_Stims_sici.Data.num_comments(r_cnt);
	mep_sd_latency = app.UITable_Unique_Stims_sici.UserData.more_info_tbl.sd_latency(r_cnt);
	mep_sd_end = app.UITable_Unique_Stims_sici.UserData.more_info_tbl.sd_end(r_cnt);
	mep_ampl_sd = app.UITable_Unique_Stims_sici.UserData.more_info_tbl.sd_mep_ampl(r_cnt);
	mep_ampl_ci1 = app.UITable_Unique_Stims_sici.UserData.more_info_tbl.ci1_mep_ampl(r_cnt);
	mep_ampl_ci2 = app.UITable_Unique_Stims_sici.UserData.more_info_tbl.ci2_mep_ampl(r_cnt);
	switch add_or_update
		case 'add'
			% add a row
			try
				conn.dbAddRow('tms_sici_icf', {'subject', 'session', 'side', 'muscle', ...
					'magstim_setting', 'bistim_setting', 'isi_ms', ...
					'stim_type',  'num_samples', 'num_meps', ...
					'mep_latency_mean', 'mep_latency_sd', 'num_mep_latencies_manually_adjusted', ...
					'mep_end_time_mean', 'mep_end_time_sd', 'num_mep_end_times_manually_adjusted', ...
					'mep_ampl_mean', 'mep_ampl_sd', 'mep_ampl_98pct_ci_1', 'mep_ampl_98pct_ci_2'...
					'num_samples_with_comments', 'num_sd', ...
					'analyzed_by', 'analyzed_when', 'verified_by', ...
					'verified_when', 'comments'}, ...
					{subject, session, side, muscle,  ...
					magstim_setting, bistim_setting, isi_ms, ...
					stim_type, num_samples, num_meps, ...
					mep_mean_latency, mep_sd_latency, num_mep_latencies_manually_adjusted, ...
					mep_mean_end_time, mep_sd_end, num_mep_end_times_manually_adjusted, ...
					mep_mean_amplitude, mep_ampl_sd, mep_ampl_ci1, mep_ampl_ci2,...
					num_samples_with_comments, num_sd,  ...
					analyzed_by, analyzed_when, verified_by, ...
					verified_when, comments});
			catch ME
				disp(ME)
				conn.dbClose()
				keyboard
			end
		case 'update'
			% update with new info
			id = db_tbl.id(r_cnt);

			try
				comments = strrep(comments, "'", "''");
				if isempty(verified_by), verified_by = ''; end

				conn.dbUpdate('tms_sici_icf',{'magstim_setting', 'bistim_setting', 'isi_ms', ...
					'stim_type',  'num_samples', 'num_meps', ...
					'mep_latency_mean', 'mep_latency_sd', 'num_mep_latencies_manually_adjusted', ...
					'mep_end_time_mean', 'mep_end_time_sd', 'num_mep_end_times_manually_adjusted', ...
					'mep_ampl_mean', 'mep_ampl_sd',  ...
					'mep_ampl_98pct_ci_1', 'mep_ampl_98pct_ci_2'...
					'num_samples_with_comments', 'num_sd', ...
					'analyzed_by', 'analyzed_when', 'verified_by', ...
					'verified_when', 'comments'}, ...
					{magstim_setting, bistim_setting, isi_ms, ...
					stim_type, num_samples, num_meps, ...
					mep_mean_latency, mep_sd_latency, num_mep_latencies_manually_adjusted, ...
					mep_mean_end_time, mep_sd_end, num_mep_end_times_manually_adjusted, ...
					mep_mean_amplitude, mep_ampl_sd, mep_ampl_ci1, mep_ampl_ci2,...
					num_samples_with_comments, num_sd,  ...
					analyzed_by, analyzed_when, verified_by, ...
					verified_when, char(comments)}, ...
					'id', uint8(id));
			catch ME
				disp(ME)
				conn.dbClose()
				keyboard
			end
	end
	
	% get the db_info from the database, if verified_when is the dummy date '2000-01-01 00:00:00'
	% change it to NULL
	check_tbl = get_sici_icf_data_from_db(app, subject, session, side, muscle, stim_type);
	if contains(check_tbl.verified_when(1), '2000-01-01 00:00:00')
		qry_str = sprintf('update tms_sici_icf SET verified_when = NULL WHERE id = %d;', check_tbl.id);
		try
			conn.dbQuery(qry_str);
		catch ME
			disp(ME)
		end
	end

end % each stim type

% close the database
conn.dbClose()

% update the in database checkbox, last update time, and database matches checkbox
app.InDatabaseCheckBox_sici.Value = true;
app.dbLastupdatedEditField_sici.Value = check_tbl.last_update{1};
app.DatabaseinfomatchesCheckBox_sici.Value = true;
return
end