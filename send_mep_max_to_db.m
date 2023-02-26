function send_mep_max_to_db(app)

% open connection to database
dbparams = get_db_login_params(app.db_str);

% see if this data is already in the database
subject = app.SubjectEditField_muscP.Value;
session = app.SessionEditField_muscP.Value;
side_muscle = app.MuscleEditField_muscP.Value;

split_cell = strsplit(side_muscle, '_');
side = split_cell{1};
muscle = split_cell{2};

db_info = get_mep_max_latency_data_from_db(app, subject, session, side, muscle);
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
% id
% subject
% session
% side
% muscle
% effective_stimulator_output
% is_eff_so_max_stim
% num_samples
% num_meps
% mep_mean_latency
% mep_mean_end_time
% mep_mean_amplitude
% num_samples_with_comments
% num_sd
% e_stim_m_max
% did_rc_plateau
% analyzed_by
% analyzed_when
% verified_by
% verfied_when
% comments

effective_stimulator_output = app.UITable_Unique_Stims.UserData.effective_stimulator_output;
is_eff_so_max_stim = app.MEPmaxatMaxSOCheckBox.Value;
num_samples = app.UITable_Unique_Stims.UserData.num_samples;
num_meps = app.UITable_Unique_Stims.UserData.num_meps;
mep_mean_latency = app.UITable_Unique_Stims.UserData.mean_latency;
mep_mean_end_time = app.UITable_Unique_Stims.UserData.mean_end;
mep_mean_amplitude = app.UITable_Unique_Stims.UserData.mep_max;
num_samples_with_comments = app.UITable_Unique_Stims.UserData.num_comments;
num_sd = app.NumSDEditField.Value;
e_stim_m_max = app.EStimMmaxEditField.Value;
did_rc_plateau = app.RecruitmentCurvePlateauedCheckBox.Value;
analyzed_by = app.AnalyzedbyEditField.Value;
analyzed_when = app.AnalysisdateEditField.Value;
if isempty(app.VerifiedbyEditField.Value)
	verified_by = 'NULL';
else
	verified_by = app.VerifiedbyEditField.Value;
end
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
				'mep_mean_latency', 'mep_mean_end_time', 'mep_mean_end_time', ...
				'mep_mean_amplitude', 'num_samples_with_comments', 'num_sd', ...
				'e_stim_m_max', 'did_rc_plateau', 'analyzed_by', 'analyzed_when', 'verified_by', ...
				'verified_when', 'comments'}, ...
				{subject, session, side, muscle,  ...
				effective_stimulator_output, is_eff_so_max_stim, num_samples, num_meps, ...
				mep_mean_latency, mep_mean_end_time, mep_mean_end_time, ...
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
				'mep_mean_latency', 'mep_mean_end_time', 'mep_mean_end_time', ...
				'mep_mean_amplitude', 'num_samples_with_comments', 'num_sd', ...
				'e_stim_m_max', 'did_rc_plateau', 'analyzed_by', 'analyzed_when', 'verified_by', ...
				'verified_when', 'comments'}, ...
				{effective_stimulator_output, is_eff_so_max_stim, num_samples, num_meps, ...
				mep_mean_latency, mep_mean_end_time, mep_mean_end_time, ...
				mep_mean_amplitude, num_samples_with_comments, num_sd, ...
				e_stim_m_max, did_rc_plateau, analyzed_by, analyzed_when, verified_by, ...
				verified_when, comments}, ...
				'id', id);
		catch ME
			disp(ME)
			keyboard
		end
end

% close the database
conn.dbClose()


return
end