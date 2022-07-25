function info = get_computed_info_mep_times(datapoint_csv_filename)
% from the datapoint csv file, get the mep_computed_info.txt file
% then read in the computed mep info

info = struct();

% datapoint_csv_filename should be named <side>_<muscle>_rc_datapoints.csv, e.g. uninv_ta_rc_datapoints.csv
[pname, fname, ~] = fileparts(datapoint_csv_filename);
side_muscle = regexprep(fname, '_((rc)|(sici))_datapoints', '');

% always look in the analysis folder path
pname = strrep(pname, [filesep, 'data', filesep],  [filesep 'analysis' filesep]);

% dir_struct = dir(pname); % all the files in the directory with the datapoint csv file
% dir_cell_list = arrayfun(@(x)(x.name), dir_struct, 'UniformOutput', false);

% computed info files are named <side>_<muscle>_rc_mep_computed_info.txt
%  e.g. inv_gastroc_rc_mep_computed_info.txt
fname = [side_muscle '_mep_computed_info.txt'];

% pat = ['^' side_muscle '_rc_mep_computed_info\.txt'];
% 
% match_cell = cellfun(@(x)regexp(x, pat, 'match'), dir_cell_list, 'UniformOutput', false);
% match_cell_array = match_cell(~cellfun(@isempty, match_cell));
% match_list = cellfun(@(x)(x{1}), match_cell_array, 'UniformOutput', false);
% if isempty(match_list)
% 	return
% end
file_name = fullfile(pname, fname);
info.file_name = file_name;

if exist(file_name, 'file') ~= 2
	return
end

% read in file, parse for the info
keywords = {'mep_beg_t' 'mep_end_t' 'epochs_used' 'analyzed_by' 'analyzed_when' ...
    'using_rc_or_sici_data' 'comments' };
defaults = {0, 0, [], '', '', '', ''};

try
	paramscell = readparamfile(file_name, keywords, defaults);
catch ME
	% keyboard
	rethrow(ME)
end

info.mep_beg_t = paramscell{1};
info.mep_end_t = paramscell{2};
info.epochs_used = paramscell{3};
info.analyzed_by = paramscell{4};
info.analyzed_when = paramscell{5};
info.using_rc_or_sici_data  = paramscell{6};
info.comments  = paramscell{7};

return
end