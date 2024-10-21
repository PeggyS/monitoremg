function send_rc_fitinfo_to_db(app, normed_or_not)

% open connection to database
dbparams = get_db_login_params(app.db_str);

% see if this data is already in the database
subject = app.SubjectEditField_muscP.Value;
session = app.SessionEditField_muscP.Value;
side_muscle = app.MuscleEditField_muscP.Value;

split_cell = strsplit(side_muscle, '_');
side = split_cell{1};
muscle = split_cell{2};

db_info = get_rc_data_from_db(subject, session, side, muscle, 'p2p', normed_or_not);
if isempty(db_info)
	% not there, need to add the data
	add_or_update = 'add';
else
	% there is something there, need to update the data
	add_or_update = 'update';
	id = db_info.id; % row id number to update
end


% get the data to send to database
% columns in the database
% data_tbl columns: 
%	norm_factor
%	mep_begin_t
%	mep_end_t
%	slope
%	s50
%	mep_min
%	mep_max
%	slope_ci_1
%	slope_ci_2
%	s50_ci_1
%	s50_ci_2
%	mep_min_ci_1
%	mep_min_ci_2
%	mep_max_ci_1
%	mep_max_ci_2
%	r_sq


effective_stimulator_output = app.UITable_Unique_Stims.UserData.effective_stimulator_output;
is_eff_so_max_stim = app.MEPmaxatMaxSOCheckBox.Value;
num_samples = app.UITable_Unique_Stims.UserData.num_samples;
num_meps = app.UITable_Unique_Stims.UserData.num_meps;
mep_mean_latency = app.UITable_Unique_Stims.UserData.mean_latency;
num_mep_latencies_manually_adjusted = app.UITable_Unique_Stims.UserData.num_latency_manual_adjust;
mep_mean_end_time = app.UITable_Unique_Stims.UserData.mean_end;
num_mep_end_times_manually_adjusted = app.UITable_Unique_Stims.UserData.num_end_manual_adjust;
mep_mean_amplitude = app.UITable_Unique_Stims.UserData.mep_max;
num_samples_with_comments = app.UITable_Unique_Stims.UserData.num_comments;
num_sd = app.NumSDEditField.Value;
e_stim_m_max = app.EStimMmaxEditField.Value;
did_rc_plateau = app.RecruitmentCurvePlateauedCheckBox.Value;
analyzed_by = app.AnalyzedbyEditField.Value;
analyzed_when = app.AnalysisdateEditField.Value;
verified_by = app.VerifiedbyEditField.Value;
verified_when = app.VerifydateEditField.Value;
comments = app.CommentsEditField.Value;

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

switch add_or_update
	case 'add'
		% add a row
		try
			conn.dbAddRow('tms_mep_max_latency', {'subject', 'session', 'side', 'muscle', ...
				'effective_stimulator_output', 'is_eff_so_max_stim', 'num_samples', 'num_meps', ...
				'mep_mean_latency', 'num_mep_latencies_manually_adjusted', 'mep_mean_end_time', ...
				'num_mep_end_times_manually_adjusted', ...
				'mep_mean_amplitude', 'num_samples_with_comments', 'num_sd', ...
				'e_stim_m_max', 'did_rc_plateau', 'analyzed_by', 'analyzed_when', 'verified_by', ...
				'verified_when', 'comments'}, ...
				{subject, session, side, muscle,  ...
				effective_stimulator_output, is_eff_so_max_stim, num_samples, num_meps, ...
				mep_mean_latency, num_mep_latencies_manually_adjusted, mep_mean_end_time, ...
				num_mep_end_times_manually_adjusted, ...
				mep_mean_amplitude, num_samples_with_comments, num_sd, ...
				e_stim_m_max, did_rc_plateau, analyzed_by, analyzed_when, verified_by, ...
				verified_when, comments});
		catch ME
			disp(ME)
			keyboard
		end
	case 'update'
		% update with new info
		try
			conn.dbUpdate('tms_mep_max_latency',{'effective_stimulator_output', 'is_eff_so_max_stim', 'num_samples', 'num_meps', ...
				'mep_mean_latency', 'num_mep_latencies_manually_adjusted',  'mep_mean_end_time',  ...
				'num_mep_end_times_manually_adjusted', ...
				'mep_mean_amplitude', 'num_samples_with_comments', 'num_sd', ...
				'e_stim_m_max', 'did_rc_plateau', 'analyzed_by', 'analyzed_when', 'verified_by', ...
				'verified_when', 'comments'}, ...
				{effective_stimulator_output, is_eff_so_max_stim, num_samples, num_meps, ...
				mep_mean_latency, num_mep_latencies_manually_adjusted, mep_mean_end_time,  ...
				num_mep_end_times_manually_adjusted, ...
				mep_mean_amplitude, num_samples_with_comments, num_sd, ...
				e_stim_m_max, did_rc_plateau, analyzed_by, analyzed_when, verified_by, ...
				verified_when, comments}, ...
				'id', id);
		catch ME
			disp(ME)
			keyboard
		end
end

% get the db_info from the database, if verified_when is the dummy date '2000-01-01 00:00:00'
% change it to NULL
db_info = get_mep_max_latency_data_from_db(app, subject, session, side, muscle);
if contains(db_info.verified_when, '2000-01-01 00:00:00')
	qry_str = sprintf('update tms_mep_max_latency SET verified_when = NULL WHERE id = %d;', db_info.id);
	try
		conn.dbQuery(qry_str);
	catch ME
		disp(ME)
	end
end

% close the database
conn.dbClose()

% update the in database checkbox, last update time, and database matches checkbox
app.InDatabaseCheckBox.Value = true;
app.dbLastupdatedEditField.Value = db_info.last_update;
app.DatabaseinfomatchesCheckBox.Value = true;
return
end