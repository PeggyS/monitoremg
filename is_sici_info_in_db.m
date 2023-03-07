function is_sici_info_in_db(app)

% is the data in the database?
subject = app.SubjectEditField_muscP.Value;
session = app.SessionEditField_muscP.Value;
side_muscle = app.MuscleEditField_muscP.Value;
split_cell = strsplit(side_muscle, '_');
side = split_cell{1};
muscle = split_cell{2};

db_tbl = get_sici_icf_data_from_db(app, subject, session, side, muscle);

% 
if ~isempty(db_tbl)
	db_tbl = sortrows(db_tbl, 'stim_type');

	app_tbl = app.UITable_Unique_Stims_sici.Data;
	% change app table's variable names to match the database variable names
	app_tbl.Properties.VariableNames = lower(app_tbl.Properties.VariableNames);
	app_tbl.Properties.VariableNames = strrep(app_tbl.Properties.VariableNames, 'num_mep', 'num_meps');
	app_tbl.Properties.VariableNames = strrep(app_tbl.Properties.VariableNames, 'mean_latency', 'mep_latency_mean');
	app_tbl.Properties.VariableNames = strrep(app_tbl.Properties.VariableNames, 'mean_end', 'mep_end_time_mean');
	app_tbl.Properties.VariableNames = strrep(app_tbl.Properties.VariableNames, 'mean_mep_ampl', 'mep_amplitude_mean');
	app_tbl.Properties.VariableNames = strrep(app_tbl.Properties.VariableNames, 'num_comments', 'num_samples_with_comments');
	app_tbl = sortrows(app_tbl, 'stim_type');

	app.InDatabaseCheckBox_sici.Value = true;
	app.dbLastupdatedEditField_sici.Value = db_tbl.last_update{1};
	% does the database info match what's shown here?

	% check main uitable data
	if isequal(app_tbl(:, {'magstim_setting' 'bistim_setting' 'isi_ms' 'stim_type' 'num_samples' 'num_meps' 'num_samples_with_comments'}), ...
				db_tbl(:, {'magstim_setting' 'bistim_setting' 'isi_ms' 'stim_type' 'num_samples' 'num_meps' 'num_samples_with_comments'}))
		match = true;
	else
		match = false;
	end
	if match == true
		% check float/double vars that may not exactly match
		var_list = {'mep_latency_mean' 'mep_end_time_mean' 'mep_amplitude_mean'};
		for v_cnt = 1:length(var_list)
			if max(abs(app_tbl.(var_list{v_cnt}) - db_tbl.(var_list{v_cnt}))) < 1e-3
				match = true;
			else
				match = false;
				break
			end
		end
	end

	if match == true
		% check more_info table
		more_tbl = sortrows(app.UITable_Unique_Stims_sici.UserData.more_info_tbl, 'stim_type');
		more_tbl.Properties.VariableNames = strrep(more_tbl.Properties.VariableNames, 'sd_latency', 'mep_latency_sd');
		more_tbl.Properties.VariableNames = strrep(more_tbl.Properties.VariableNames, 'sd_end', 'mep_end_time_sd');
		more_tbl.Properties.VariableNames = strrep(more_tbl.Properties.VariableNames, 'sd_mep_ampl', 'mep_amplitude_sd');
		more_tbl.Properties.VariableNames = strrep(more_tbl.Properties.VariableNames, 'ci1_mep_ampl', 'mep_ampl_98pct_ci_1');
		more_tbl.Properties.VariableNames = strrep(more_tbl.Properties.VariableNames, 'ci2_mep_ampl', 'mep_ampl_98pct_ci_2');
		var_list = {'mep_latency_sd' 'mep_end_time_sd' 'mep_amplitude_sd' 'mep_ampl_98pct_ci_1' 'mep_ampl_98pct_ci_2'};
		for v_cnt = 1:length(var_list)
			if max(abs(more_tbl.(var_list{v_cnt}) - db_tbl.(var_list{v_cnt}))) < 1e-3
				match = true;
			else
				match = false;
				break
			end
		end
	end

	% check app fields
	if match && ...
		db_tbl.num_sd(1) == app.NumSDEditField_sici.Value && ...
		contains(db_tbl.analyzed_by{1}, app.AnalyzedbyEditField_sici.Value) && ...
		contains(db_tbl.analyzed_when{1}, app.AnalysisdateEditField_sici.Value) && ...
		contains(db_tbl.verified_by{1}, app.VerifiedbyEditField_sici.Value) && ...
		contains(db_tbl.verified_when{1}, app.VerifydateEditField_sici.Value) && ...
		contains(db_tbl.comments{1}, app.CommentsEditField_sici.Value)  
		match = true;
	else
		match = false;
	end
	if match == true
		app.DatabaseinfomatchesCheckBox_sici.Value = true;
	else
		app.DatabaseinfomatchesCheckBox_sici.Value = false;
	end
else
	app.InDatabaseCheckBox_sici.Value = false;
	app.dbLastupdatedEditField_sici.Value = '';
	app.DatabaseinfomatchesCheckBox_sici.Value = false;
end % info in the database

return
end