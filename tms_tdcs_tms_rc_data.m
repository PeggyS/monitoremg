function tms_tdcs_tms_rc_data()

% output variables:
% subject
% session_num
% session_descr
% pre_post
% norm or not norm
% <inv|uninv><ta|gastroc>mep_ampl (max mep value)
% <inv|uninv><ta|gastroc>rc_auc

% <inv|uninv>ts
% <inv|uninv>sici_pct_ts
% <inv|uninv>icf_pct_ts


subj_list = {'s2754tdvg'};
muscle_list = {'inv_ta', 'uninv_ta', 'inv_gastroc', 'uninv_gastroc'};
norm_list = {'norm' 'not_norm'};

out_tbl = table();

for s_cnt = 1:length(subj_list)
	subj = subj_list{s_cnt};
	for m_cnt = 1:length(muscle_list)
		muscle = muscle_list{m_cnt};

		for n_cnt = 1:length(norm_list)
			norm_str = norm_list{n_cnt};

			% find fit info files
			regexp_str = ['(.*' filesep muscle '_p2p_fit_info_' norm_str '.txt)$'];
			subj_dir = [pwd filesep subj];
			file_list = regexpdir(subj_dir,regexp_str);
			if length(file_list) < 1
				fprintf('found no %s files.\n', regexp_str);
				keyboard
			end
			
			% reset commonStimLevelsVector
			commonStimLevelsVector = [];
			info = {};
			% read in each file
			for f_cnt = 1:length(file_list)
				tmp = read_fit_info(file_list{f_cnt});
				info{f_cnt} = tmp;
				% get common auc stim levels
				if isempty(commonStimLevelsVector)
					commonStimLevelsVector = info{f_cnt}.stimLevels;
				else
					commonStimLevelsVector = intersect(commonStimLevelsVector, info{f_cnt}.stimLevels);
				end
			end

			% for each file, save the info in the table
			for f_cnt = 1:length(file_list)
				% parse the path
				% parse the filename
				[pathname, filename, ~] = fileparts(file_list{f_cnt});

				% get the session name format: session#
				sess_cell = regexp(pathname, '(session\d+)', 'match');
				% get session type 
				type_path = regexprep(pathname, '(pre|post)', '');
				type_cell = readtextfile([type_path 'stim_type.txt']);
				% pre or post
				pre_post_cell = regexp(pathname, '(pre|post)', 'match');

				% mep_max
				mep_max = max(info{f_cnt}.aucMeanVals);

				% compute auc for common stim levels
				stim_level_msk = ismember(info{f_cnt}.stimLevels, commonStimLevelsVector);
				commonStimLevels = info{f_cnt}.stimLevels(stim_level_msk);
				commonAucMeanVals = info{f_cnt}.aucMeanVals(stim_level_msk);
				auc = polyarea([commonStimLevels(1) commonStimLevels commonStimLevels(end)], ...
					[0 commonAucMeanVals 0]);


				tmp_tbl = table( {subj}, sess_cell, type_cell, pre_post_cell, {muscle}, {norm_str}, mep_max, auc, ...
					'VariableNames', {'subject', 'session_num', 'session_type', 'pre_post', 'muscle' 'norm_or_not', 'mep_max', 'rc_auc'});
				if isempty(out_tbl)
					out_tbl = tmp_tbl;
				else
					out_tbl = vertcat(out_tbl, tmp_tbl);
				end

			end %file

		end %norm not_norm
	end % muscle

end % subject

% name and save th table
today_str = char(string(yyyymmdd(datetime('now'))));
save_var = 'tms_treadmill_tms_rc_data';
fname = [save_var today_str '.csv'];
writetable(out_tbl, fname)

