function rc_fitinfo_to_db(analysisDir)
% send the data in the *fit_info*.txt files to the tdcs_vgait.tms_rc_measures table in the database
%
% analysisDir is a string to the top level of the directory structure, e.g.
% /Users/peggy/Documents/BrainLab/tDCS Gait/Analysis/ta_rc/s2718tdvg
%	Default analysisDir is the current directory.

if nargin < 1
	analysisDir = pwd;
end

% find fit info files
file_list = regexpdir(analysisDir,'(_fit_info_).+\.txt$');	% fixed for mac 2013a
if length(file_list) < 1
	disp('found no _fit_info_*.txt files.')
	return;
end

% open connection to database
dbparams = get_db_login_params('tdcs_vgait');

try
	conn = dbConnect(dbparams.dbname, dbparams.user, dbparams.password, dbparams.serveraddr);
catch
	warning('could not connect to database')
	return
end
% since this takes a while, display a waitbar
hwb = waitbar(0, 'Sending MEP Recruitment Curve Data to the Database');

count = length(file_list);
for i = 1:count
	% update the waitbar
	waitbar(i/count, hwb);	
	
	% get the file date
	d = dir(file_list{i});
	file_date_num = d.datenum;
	
	% parse the filename
	[pathname, filename, ~] = fileparts(file_list{i});
	
	% get the subject name format: [s|c][####][xxxx]
	subj_str = regexp(pathname, '([sc][\d]+\w+)', 'match');
	subj_str = subj_str{1};
    
	
	% pre, mid, post or followup session
	session_str = lower(regexp(pathname, '(pre|mid|post|followup)', 'match'));
	if isempty(session_str)		% no pre mid post or fu in the path
		error('no session found in pathname %s', pathname)
	end
	session_str = session_str{1};
	
	% involved or uninvolved side
	side = regexpi(filename, '^(inv|uninv)', 'match');
	side = side{1};
	
	% muscle
	muscle = lower(regexpi(filename, '_(gastroc|ta)_', 'match'));
	muscle = muscle{1};
	muscle = strrep(muscle, '_', '');
	
	% read in the data
	ds = readRcInfo(file_list{i});

	% check to see if this is already in the database
	db_data = conn.dbSearch('tms_rc_measures', {'norm_factor','last_update', 'id'}, 'subject', subj_str, ...
		'session', session_str, 'side', side, 'muscle', muscle, ...
		'mep_method', ds.mepMethod);
	
	% if the info is not in the database or the file time is more recent than
	% the database time for this info
	% matching file info & db row for the norm factor == or ~= 1
	add_or_update = 'add';
	for r_cnt = 1:size(db_data,1)
		if ds.norm_factor == 1 % entering not normed data
			if db_data{r_cnt,1} == 1 % not norm database row
				if file_date_num > datenum(db_data{r_cnt,2})
					add_or_update = 'update';
					update_id = db_data{r_cnt,3};
				else
					add_or_update = 'skip';
				end
			end
		else % entering normed data
			if db_data{r_cnt,1} ~= 1 % norm database row
				if file_date_num > datenum(db_data{r_cnt,2})
					add_or_update = 'update';
					update_id = db_data{r_cnt,3};
				else
					add_or_update = 'skip';
				end
			end
		end
	end
	
	
	if ~strcmp(add_or_update, 'skip')
		disp(['processing ' file_list{i}])
		
		auc_vals_str = num2str(ds.aucMeanVals);
		assert(length(auc_vals_str)<=256, ...
			'aucMeanVals converts to a string with %d chars -> longer than allowed by the database', ...
			length(auc_vals_str))
		stim_levels_str = num2str(ds.stimLevels);
		assert(length(stim_levels_str)<=256, ...
			'stimLevels converts to a string with %d chars -> longer than allowed by the database', ...
			length(stim_levels_str))
		
		switch add_or_update
			case 'add'
				% add a row
				try
					conn.dbAddRow('tms_rc_measures', {'subject', 'session', 'side', 'muscle', 'mep_method', ...
						'norm_factor', 'mep_begin_t', 'mep_end_t', 'slope', 's50', ...
						'mep_min', 'mep_max', 'slope_ci_1', 'slope_ci_2', 's50_ci_1', 's50_ci_2', ...
						'mep_min_ci_1', 'mep_min_ci_2', 'mep_max_ci_1', 'mep_max_ci_2', 'r_sq', ...
						'auc', 'auc_mean_values', 'auc_stim_levels'}, ...
						{subj_str, session_str, side, muscle, ds.mepMethod, ...
						ds.norm_factor, ds.mep_begin_t, ds.mep_end_t, ds.slope, ds.s50, ...
						ds.mepMin, ds.mepMax, ds.slopeCi(1), ds.slopeCi(2), ds.s50Ci(1), ds.s50Ci(2), ...
						ds.mepMinCi(1), ds.mepMinCi(2), ds.mepMaxCi(1), ds.mepMaxCi(2), ds.Rsq, ...
						ds.auc, auc_vals_str, stim_levels_str});
				catch ME
					match_cell = regexp(ME.message, '''.*''','match');
					match_str = strrep(match_cell{1}, '''', '');
					if contains(match_str, 'mep')
						disp(['current file does not contain ' match_str])
					else
						keyboard
					end
				end
			case 'update'
				% update with new info
				try
					conn.dbUpdate('tms_rc_measures',{'norm_factor', 'mep_begin_t', 'mep_end_t', 'slope', 's50', ...
						'mep_min', 'mep_max', 'slope_ci_1', 'slope_ci_2', 's50_ci_1', 's50_ci_2', ...
						'mep_min_ci_1', 'mep_min_ci_2', 'mep_max_ci_1', 'mep_max_ci_2', 'r_sq', ...
						'auc', 'auc_mean_values', 'auc_stim_levels'}, ...
						{ds.norm_factor, ds.mep_begin_t, ds.mep_end_t, ds.slope, ds.s50, ...
						ds.mepMin, ds.mepMax, ds.slopeCi(1), ds.slopeCi(2), ds.s50Ci(1), ds.s50Ci(2), ...
						ds.mepMinCi(1), ds.mepMinCi(2), ds.mepMaxCi(1), ds.mepMaxCi(2), ds.Rsq, ...
						ds.auc, auc_vals_str, stim_levels_str}, ...
						'id', update_id);
				catch ME
					keyboard
				end
		end
	end
	
end

% close the database
conn.dbClose()

% close the waitbar
close(hwb);

% ------------------------------------------------------------------------------
function ds = readRcInfo(fname)
ds = dataset();
% read in the file as text
txt = readtextfile(fname);
if isempty(txt)
	% nothing read in
	disp('no text to parse')
	return
end

% separate each line at the colon ':'
txt = cellfun(@(x)(regexp(x,':','split')), txt, 'uniformoutput', false);
txt = cellfun(@strtrim,txt, 'uniformoutput', false);		% remove extra spaces

% go through each line of text
for kk = 1:length(txt)
	% variable name is in the first cell, value is in the second
	% normFactorStr and pctVsetting are strings, all others are 1 or 2 numbers
	if regexp(txt{kk}{1}, 'normFactorStr|pctVsetting|mepMethod|coil')
		ds = horzcat(ds, dataset({txt{kk}{2}, txt{kk}{1}}));
	else
		ds = horzcat(ds, dataset({str2num(txt{kk}{2}), txt{kk}{1}}));
	end
end

