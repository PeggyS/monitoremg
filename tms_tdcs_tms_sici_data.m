function tms_tdcs_tms_sici_data()

% output variables:
% subject
% session_num
% session_descr
% pre_post

% <inv|uninv>ts
% <inv|uninv>sici_pct_ts
% <inv|uninv>icf_pct_ts


subj_list = {'s2754tdvg'};
muscle_list = {'inv_ta', 'uninv_ta'};


out_tbl = table();

for s_cnt = 1:length(subj_list)
	subj = subj_list{s_cnt};
	for m_cnt = 1:length(muscle_list)
		muscle = muscle_list{m_cnt};

			% find sici info files
			regexp_str = ['(.*' filesep muscle '_p2p_sici_info_not_norm.txt)$'];
			subj_dir = [pwd filesep subj];
			file_list = regexpdir(subj_dir,regexp_str);
			if length(file_list) < 1
				fprintf('found no %s files.\n', regexp_str);
				keyboard
			end
			
	
			% for each file, save the info in the table
			for f_cnt = 1:length(file_list)
				% read in the info
				tmp = read_sici_info(file_list{f_cnt});
				info{f_cnt} = tmp;

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



				tmp_tbl = table( {subj}, sess_cell, type_cell, pre_post_cell, {muscle},  ...
					info{f_cnt}.ts_mean, info{f_cnt}.sici_mean, info{f_cnt}.icf_mean, ...
					info{f_cnt}.sici_mean / info{f_cnt}.ts_mean *100, info{f_cnt}.icf_mean / info{f_cnt}.ts_mean *100, ...
					'VariableNames', {'subject', 'session_num', 'session_type', 'pre_post', 'muscle', ...
					'ts', 'sici', 'icf', ...
					'sici_pct_ts', 'icf_pct_ts'});
				if isempty(out_tbl)
					out_tbl = tmp_tbl;
				else
					out_tbl = vertcat(out_tbl, tmp_tbl);
				end

			end %file


	end % muscle

end % subject

% name and save th table
today_str = char(string(yyyymmdd(datetime('now'))));
save_var = 'tms_treadmill_tms_sici_data';
fname = [save_var today_str '.csv'];
writetable(out_tbl, fname)

