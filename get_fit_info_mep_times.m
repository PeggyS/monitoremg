function [mep_beg_t, mep_end_t] = get_fit_info_mep_times(datapoint_csv_filename)
% from the datapoint csv file, guess a fit info file, then read in the 
% begin & end mep times from the fit info file

% datapoint_csv_filename should be named <side>_<muscle>_rc_datapoints.csv, e.g. uninv_ta_rc_datapoints.csv
[pname, fname, ext] = fileparts(datapoint_csv_filename);
side_muscle = regexprep(fname, '_((rc)|(sici))_datapoints', '');

% always look in the analysis folder path
pname = strrep(pname, '/data/', '/analysis/');

dir_struct = dir(pname); % all the files in the directory with the datapoint csv file
dir_cell_list = arrayfun(@(x)(x.name), dir_struct, 'UniformOutput', false);

% fit info files are named <side>_<muscle>_<mep type>_fit_info_<norm
% type>.txt, e.g. uninv_ta_p2p_fit_info_norm.txt
fit_info_pat = ['^' side_muscle '_.*' '_fit_info_.*'];

match_cell = cellfun(@(x)regexp(x, fit_info_pat, 'match'), dir_cell_list, 'UniformOutput', false);
match_cell_array = match_cell(~cellfun(@isempty, match_cell));
match_list = cellfun(@(x)(x{1}), match_cell_array, 'UniformOutput', false);
if isempty(match_list)
	mep_beg_t = 10;
	mep_end_t = 100;
	return
end

% read in each matching fit info file, parse for the mep_beg_t
keywords = {'mep_beg_t' 'mep_end_t'};
defaults = {0, 0};
mep_beg_vec = zeros(1,length(match_list));
mep_end_vec = zeros(1,length(match_list));
for f_cnt = 1:length(match_list)
	try
		fit_file = fullfile(pname, match_list{f_cnt});
		paramscell = readparamfile(fit_file, keywords, defaults);
	catch ME
		keyboard
	end
	mep_beg_vec(f_cnt) = paramscell{1};
	mep_end_vec(f_cnt) = paramscell{2};
end

% check for all the mep_beg_t and end_t to be the same
mep_beg_t = unique(mep_beg_vec);
assert(length(mep_beg_t) == 1, 'more than 1 mep begin time in fit info files for %s', pname)
mep_end_t = unique(mep_end_vec);
assert(length(mep_end_t) == 1, 'more than 1 mep end time in fit info files for %s', pname)
