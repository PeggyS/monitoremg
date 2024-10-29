function is_mep_info_in_db(app)

% is the data in the mep max & latency table?
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
	match = false;
	if db_info.effective_stimulator_output == app.UITable_Unique_Stims.UserData.effective_stimulator_output && ...
		db_info.is_eff_so_max_stim == app.MEPmaxatMaxSOCheckBox.Value && ...
		db_info.num_samples == app.UITable_Unique_Stims.UserData.num_samples && ...
		db_info.num_meps == app.UITable_Unique_Stims.UserData.num_meps && ...
		((abs(db_info.mep_mean_latency - app.UITable_Unique_Stims.UserData.mean_latency) < 1e-2) || ...
				isnan(db_info.mep_mean_latency) && isnan(app.UITable_Unique_Stims.UserData.mean_latency))  && ...
		(abs(db_info.num_mep_latencies_manually_adjusted - app.UITable_Unique_Stims.UserData.num_latency_manual_adjust) < 1e-2 || ...
			isnan(db_info.num_mep_latencies_manually_adjusted) && isnan(app.UITable_Unique_Stims.UserData.num_latency_manual_adjust)) && ...
		(abs(db_info.mep_mean_end_time - app.UITable_Unique_Stims.UserData.mean_end) < 1e-2 || ...
		    isnan(db_info.mep_mean_end_time) && isnan(app.UITable_Unique_Stims.UserData.mean_end)) && ...
		(abs(db_info.num_mep_end_times_manually_adjusted - app.UITable_Unique_Stims.UserData.num_end_manual_adjust) < 1e-2  || ...
		     isnan(db_info.num_mep_end_times_manually_adjusted) && isnan(app.UITable_Unique_Stims.UserData.num_end_manual_adjust) ) && ...
		abs(db_info.mep_mean_amplitude - app.UITable_Unique_Stims.UserData.mep_max) < 1e-2 && ...
		db_info.num_samples_with_comments == app.UITable_Unique_Stims.UserData.num_comments && ...
		db_info.num_sd == app.NumSDEditField.Value && ...
		abs(db_info.e_stim_m_max - app.EStimMmaxEditField.Value) < 1e-3 && ...
		db_info.did_rc_plateau == app.RecruitmentCurvePlateauedCheckBox.Value && ...
		contains(db_info.analyzed_by, app.AnalyzedbyEditField.Value) && ...
		contains(db_info.analyzed_when, app.AnalysisdateEditField.Value) && ...
		contains(db_info.verified_by, app.VerifiedbyEditField.Value) && ...
		contains(db_info.verified_when, app.VerifydateEditField.Value) && ...
		contains(db_info.comments, app.CommentsEditField.Value)  
		match = true;
	end

	app.DatabaseinfomatchesCheckBox.Value = match;
else
	app.InDatabaseCheckBox.Value = false;
	app.dbLastupdatedEditField.Value = '';
	app.DatabaseinfomatchesCheckBox.Value = false;
end % info in the database


% check for info in the rc table
app.InDatabaseCheckBox_2.Value = false;
app.dbLastupdatedEditField_2.Value = '';
app.DatabaseinfomatchesCheckBox_2.Value = false;

rc_info_norm = get_rc_data_from_db(subject, session, side, muscle, 'p2p', 'norm');
if ~isempty(rc_info_norm)
	% does the database info match what's shown here?
	match = compare_rc_info(app.UITable_Unique_Stims.UserData.rc_info.norm, rc_info_norm);
	rc_info_norm.matches_db = match;
else
	rc_info_norm.matches_db = false;
end

rc_info_not_norm = get_rc_data_from_db(subject, session, side, muscle, 'p2p', 'not_norm');
if ~isempty(rc_info_not_norm)
	% does the database info match what's shown here?
	match = compare_rc_info(app.UITable_Unique_Stims.UserData.rc_info.not_norm, rc_info_not_norm);
	rc_info_not_norm.matches_db = match;
else
	rc_info_not_norm.matches_db = false;
end

% if both norm & not norm match and are in the database
app.InDatabaseCheckBox_2.Value = rc_info_norm.matches_db & rc_info_not_norm.matches_db;
app.DatabaseinfomatchesCheckBox_2.Value = rc_info_norm.matches_db & rc_info_not_norm.matches_db;
if rc_info_norm.matches_db && rc_info_not_norm.matches_db
	max_update_date = max([datetime(rc_info_norm.last_update{:}) datetime(rc_info_not_norm.last_update{:})]);
	app.dbLastupdatedEditField_2.Value = string(max_update_date, 'yyyy-MM-dd HH:mm:ss');
else
	app.dbLastupdatedEditField_2.Value = '';
end

return
end