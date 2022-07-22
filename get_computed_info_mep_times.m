function info = get_computed_info_mep_times(datapoint_csv_filename)
% from the datapoint csv file, get the mep_computed_info.txt file
% then read in the computed mep info

info = struct();

% datapoint_csv_filename should be named <side>_<muscle>_rc_datapoints.csv, e.g. uninv_ta_rc_datapoints.csv
[pname, fname, ext] = fileparts(datapoint_csv_filename);
side_muscle = regexprep(fname, '_((rc)|(sici))_datapoints', '');

% always look in the analysis folder path
pname = strrep(pname, '/data/', '/analysis/');

dir_struct = dir(pname); % all the files in the directory with the datapoint csv file
dir_cell_list = arrayfun(@(x)(x.name), dir_struct, 'UniformOutput', false);

% computed info files are named <side>_<muscle>_rc_mep_computed_info.txt
%  e.g. inv_gastroc_rc_mep_computed_info.txt
pat = ['^' side_muscle '_rc_mep_computed_info\.txt'];

match_cell = cellfun(@(x)regexp(x, pat, 'match'), dir_cell_list, 'UniformOutput', false);
match_cell_array = match_cell(~cellfun(@isempty, match_cell));
match_list = cellfun(@(x)(x{1}), match_cell_array, 'UniformOutput', false);
if isempty(match_list)
	return
end

% read in file, parse for the info
keywords = {'mep_begin_t' 'mep_end_t' 'epochs_used' 'analyzed_by' 'analyzed_when' };
defaults = {0, 0, 0, '', ''};

try
	fname = match_list{1};
	paramscell = readparamfile(fullfile(pname, fname), keywords, defaults);
catch ME
	% keyboard
	rethrow(ME)
end

info.mep_beg_t = paramscell{1};
info.mep_end_t = paramscell{2};
info.epochs_used = paramscell{3};
info.analyzed_by = paramscell{4};
info.analyzed_when = paramscell{5};

return
end