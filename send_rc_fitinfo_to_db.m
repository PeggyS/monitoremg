function success = send_rc_fitinfo_to_db(app, normed_or_not)

success = false;

% no need to update if database already matches
if app.DatabaseinfomatchesCheckBox_2.Value
	return
end

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

info = app.UITable_Unique_Stims.UserData.rc_info.(normed_or_not);
auc_vals_str = num2str(info.aucMeanVals);
		assert(length(auc_vals_str)<=256, ...
			'aucMeanVals converts to a string with %d chars -> longer than allowed by the database', ...
			length(auc_vals_str))
		stim_levels_str = num2str(info.stimLevels);
		assert(length(stim_levels_str)<=256, ...
			'stimLevels converts to a string with %d chars -> longer than allowed by the database', ...
			length(stim_levels_str))

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
			conn.dbAddRow('tms_rc_measures', {'subject', 'session', 'side', 'muscle', 'mep_method', ...
						'norm_factor', 'mep_beg_t', 'mep_end_t', 'slope', 's50', ...
						'mep_min', 'mep_max', 'slope_ci_1', 'slope_ci_2', 's50_ci_1', 's50_ci_2', ...
						'mep_min_ci_1', 'mep_min_ci_2', 'mep_max_ci_1', 'mep_max_ci_2', 'r_sq', ...
						'auc', 'auc_mean_values', 'auc_stim_levels', 'stimulator_mode', ...
						'analyzed_by', 'analyzed_when'}, ...
						{subject, session, side, muscle, info.mepMethod, ...
						info.norm_factor, info.mep_beg_t, info.mep_end_t, info.slope, info.s50, ...
						info.mepMin, info.mepMax, info.slopeCi(1), info.slopeCi(2), info.s50Ci(1), info.s50Ci(2), ...
						info.mepMinCi(1), info.mepMinCi(2), info.mepMaxCi(1), info.mepMaxCi(2), info.Rsq, ...
						info.auc, auc_vals_str, stim_levels_str, info.stimulator_mode, ...
						info.analyzed_by, info.analyzed_when});
		catch ME
			disp(ME)
			conn.dbClose()
			keyboard
		end
	case 'update'
		% update with new info
		try
			conn.dbUpdate('tms_rc_measures',{'norm_factor', 'mep_beg_t', 'mep_end_t', 'slope', 's50', ...
						'mep_min', 'mep_max', 'slope_ci_1', 'slope_ci_2', 's50_ci_1', 's50_ci_2', ...
						'mep_min_ci_1', 'mep_min_ci_2', 'mep_max_ci_1', 'mep_max_ci_2', 'r_sq', ...
						'auc', 'auc_mean_values', 'auc_stim_levels', 'stimulator_mode', ...
						'analyzed_by', 'analyzed_when'}, ...
						{info.norm_factor, info.mep_beg_t, info.mep_end_t, info.slope, info.s50, ...
						info.mepMin, info.mepMax, info.slopeCi(1), info.slopeCi(2), info.s50Ci(1), info.s50Ci(2), ...
						info.mepMinCi(1), info.mepMinCi(2), info.mepMaxCi(1), info.mepMaxCi(2), info.Rsq, ...
						info.auc, auc_vals_str, stim_levels_str, info.stimulator_mode, ...
						info.analyzed_by, info.analyzed_when}, ...
						'id', id);
		catch ME
			disp(ME)
			conn.dbClose()
			keyboard
		end
end


% get the db_info from the database
db_info = get_rc_data_from_db(subject, session, side, muscle, 'p2p', normed_or_not);

% close the database
conn.dbClose()

success = true;
% update the last update time
app.dbLastupdatedEditField_2.Value = db_info.last_update{1};

return
end