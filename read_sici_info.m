function info = read_sici_info(file_name)

info = struct();

if exist(file_name, 'file') ~= 2
	return
end

% read in file, parse for the info
keywords = { 'ts_n' 'ts_mean' 'ts_ci' 'sici_n' 'sici_mean' 'sici_ci' ...
	'icf_n' 'icf_mean' 'icf_ci' 'ts_value' 'cs_value' 'icf_isi' 'sici_isi' ...
	'test_stim_isi' 'mepMethod' 'mep_norm_factor' 'mep_beg_t' 'mep_end_t' ...
	'analyzed_by' 'analyzed_when'};
	
defaults = {0, 0, [], 0, 0, [], 0, 0, [], 0, 0, 0, 0, 0, 0, 0, 0, 0, '', ''};

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
info.mep_beg_t		= paramscell{17};
info.mep_end_t		= paramscell{18};
info.analyzed_by	= paramscell{19};
info.analyzed_when	= paramscell{20};

return
end % read_fit_info