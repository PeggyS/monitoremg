function match = compare_rc_info(rc_info_from_file, rc_info_from_db)

match = false;
db_auc_mean_vals = str2double(split(rc_info_from_db.auc_mean_values))';
db_auc_stim_levels = str2double(split(rc_info_from_db.auc_stim_levels))';

if        abs(rc_info_from_file.norm_factor - rc_info_from_db.norm_factor) < 1e-4 && ...
          abs(rc_info_from_file.mep_beg_t - rc_info_from_db.mep_beg_t) < 1e-4 && ...
          abs(rc_info_from_file.mep_end_t - rc_info_from_db.mep_end_t) < 1e-4 && ...
              abs(rc_info_from_file.slope - rc_info_from_db.slope) < 1e-4 && ...
                abs(rc_info_from_file.s50 - rc_info_from_db.s50) < 1e-4 && ...
             abs(rc_info_from_file.mepMin - rc_info_from_db.mep_min) < 1e-4 && ...
             abs(rc_info_from_file.mepMax - rc_info_from_db.mep_max) < 1e-4 && ...
            abs(rc_info_from_file.slopeCi(1) - rc_info_from_db.slope_ci_1) < 1e-4 && ...
			abs(rc_info_from_file.slopeCi(2) - rc_info_from_db.slope_ci_2) < 1e-4 && ...
              abs(rc_info_from_file.s50Ci(1) - rc_info_from_db.s50_ci_1) < 1e-4 && ...
			  abs(rc_info_from_file.s50Ci(2) - rc_info_from_db.s50_ci_2) < 1e-4 && ...
           abs(rc_info_from_file.mepMinCi(1) - rc_info_from_db.mep_min_ci_1) < 1e-4 && ...
		   abs(rc_info_from_file.mepMinCi(2) - rc_info_from_db.mep_min_ci_2) < 1e-4 && ...
           abs(rc_info_from_file.mepMaxCi(1) - rc_info_from_db.mep_max_ci_1) < 1e-4 && ...
		   abs(rc_info_from_file.mepMaxCi(2) - rc_info_from_db.mep_max_ci_2) < 1e-4 && ...
                abs(rc_info_from_file.Rsq - rc_info_from_db.r_sq) < 1e-4 && ...
                abs(rc_info_from_file.auc - rc_info_from_db.auc) < 1e-4 && ...
        max(abs(rc_info_from_file.aucMeanVals-db_auc_mean_vals)) < 1e-4 && ...
        max(abs(rc_info_from_file.stimLevels-db_auc_stim_levels)) < 1e-4 && ...
    contains(rc_info_from_file.stimulator_mode, rc_info_from_db.stimulator_mode) && ...
        contains(rc_info_from_file.analyzed_by, rc_info_from_db.analyzed_by) && ...
      contains(rc_info_from_file.analyzed_when, rc_info_from_db.analyzed_when)

	match = true;
else
% 	keyboard
end

return
end