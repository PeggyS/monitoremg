function info = get_dp_analysis_info(datapoint_csv_filename)
% from knowing the datapoint csv file name, get the dp_analysis_info.txt
% file if there is one.
% then read in the info

info = struct();

% datapoint_csv_filename should be named <side>_<muscle>_rc_datapoints.csv, e.g. uninv_ta_rc_datapoints.csv

% append _analysis_info.txt 
info_fname = strrep(datapoint_csv_filename, 'datapoints.csv', 'datapoints_analysis_info.txt');
[pname, fname, ext] = fileparts(info_fname);

% always look in the analysis folder path
pname = strrep(pname, [filesep, 'data', filesep],  [filesep 'analysis' filesep]);

info_fname = fullfile(pname, [fname ext]);

info.file_name = info_fname;

if exist(info_fname, 'file') ~= 2
	return
end

% read in file, parse for the info
keywords = {'analyzed_by' 'analyzed_when' 'comments', 'num_std_dev', 'rc_plateau', ...
	'e_stim_m_max_uV', 'verified_by', 'verified_when'};
defaults = {'', '', '', [], [], [], '', ''};

try
	paramscell = readparamfile(info_fname, keywords, defaults);
catch ME
	% keyboard
	rethrow(ME)
end

info.analyzed_by = paramscell{1};
info.analyzed_when = paramscell{2};
info.comments  = paramscell{3};
info.num_std_dev = paramscell{4};
info.rc_plateau = paramscell{5};
info.e_stim_m_max_uV = paramscell{6};
info.verified_by = paramscell{7};
info.verified_when = paramscell{8};

return
end