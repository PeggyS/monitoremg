function info = read_sici_info(file_name)

info = struct();

if exist(file_name, 'file') ~= 2
	return
end

% read in file, parse for the info
keywords = { 'ts_n' 'ts_mean' 'ts_ci' 'sici_n' 'sici_mean' 'sici_ci' ...
	'icf_n' 'icf_mean' 'icf_ci' 'ts_value' 'cs_value' 'icf_isi' 'sici_isi' ...
	'test_stim_isi' 'mepMethod' 'mep_norm_factor' ...
	'ts_mep_beg_t' 'ts_mep_end_t' 'ts_epochs_used' 'ts_num_sd' ...
	'sici_mep_beg_t' 'sici_mep_end_t' 'sici_epochs_used' 'sici_num_sd' ...
	'icf_mep_beg_t' 'icf_mep_end_t' 'icf_epochs_used' 'icf_num_sd' ...
	'analyzed_by' 'analyzed_when' 'comments'};
	
defaults = {0, 0, [], 0, 0, [], 0, 0, [], 0, 0, 0, 0, 0, 0, 0, ...
	0, 0, [], 0, ...
	0, 0, [], 0, ...
	0, 0, [], 0, '', '', ''};

try
	paramscell = readparamfile(file_name, keywords, defaults);
catch ME
	% keyboard
	rethrow(ME)
end

info.ts_n			= paramscell{1};
info.ts_mean		= paramscell{2};
info.ts_ci			= paramscell{3};
info.sici_n			= paramscell{4};
info.sici_mean		= paramscell{5};
info.sici_ci		= paramscell{6};
info.icf_n			= paramscell{7};
info.icf_mean		= paramscell{8};
info.icf_ci			= paramscell{9};
info.ts_value		= paramscell{10};
info.cs_value		= paramscell{11};
info.icf_isi		= paramscell{12};
info.sici_isi		= paramscell{13};
info.test_stim_isi	= paramscell{14};
info.mepMethod		= paramscell{15};
info.mep_norm_factor = paramscell{16};
info.ts_mep_beg_t		= paramscell{17};
info.ts_mep_end_t		= paramscell{18};
info.ts_epochs_used		= paramscell{19};
info.ts_num_sd		    = paramscell{20};
info.sici_mep_beg_t		= paramscell{21};
info.sici_mep_end_t		= paramscell{22};
info.sici_epochs_used	= paramscell{23};
info.sici_num_sd		= paramscell{24};
info.icf_mep_beg_t		= paramscell{25};
info.icf_mep_end_t		= paramscell{26};
info.icf_epochs_used	= paramscell{27};
info.icf_num_sd		= paramscell{28};
info.analyzed_by	= paramscell{29};
info.analyzed_when	= paramscell{30};
info.comments	= paramscell{31};

return
end % read_fit_info