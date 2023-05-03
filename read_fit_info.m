function info = read_fit_info(file_name)

info = struct();

if exist(file_name, 'file') ~= 2
	return
end

% read in file, parse for the info
keywords = {'mepMethod' 'norm_factor' 'mep_beg_t' 'mep_end_t' 'slope' 's50' ...
	'mepMin' 'mepMax' 'slopeCi' 's50Ci' 'mepMinCi' 'mepMaxCi' 'Rsq' ...
	'auc' 'aucMeanVals' 'stimLevels' 'stimulator_mode' 'analyzed_by' 'analyzed_when' ...
	'verified_by' 'verified_when'};
	
defaults = {'', 0, 0, 0, 0, 0, 0, 0, [], [], [], [], 0, 0, [], [], '', '', '', '', ''};

try
	paramscell = readparamfile(file_name, keywords, defaults);
catch ME
	% keyboard
	rethrow(ME)
end

info.mepMethod       = paramscell{1};
info.norm_factor     = paramscell{2};
info.mep_beg_t       = paramscell{3};
info.mep_end_t       = paramscell{4};
info.slope           = paramscell{5};
info.s50             = paramscell{6};
info.mepMin          = paramscell{7};
info.mepMax          = paramscell{8};
info.slopeCi         = paramscell{9};
info.s50Ci           = paramscell{10};
info.mepMinCi        = paramscell{11};
info.mepMaxCi        = paramscell{12};
info.Rsq             = paramscell{13};
info.auc             = paramscell{14};
info.aucMeanVals     = paramscell{15};
info.stimLevels      = paramscell{16};
info.stimulator_mode = paramscell{17};
info.analyzed_by     = paramscell{18};
info.analyzed_when   = paramscell{19};
info.verified_by     = paramscell{20};
info.verified_when   = paramscell{21};

return
end % read_fit_info