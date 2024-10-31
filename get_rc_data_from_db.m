function data_tbl = get_rc_data_from_db(subject, session, side, muscle, mep_method, normed_or_not)
% extract the rc data for the specified subject
% data_tbl columns: 
%	norm_factor
%	mep_begin_t - not accurate, for mep times used the tms_mep_max_latency table
%	mep_end_t - not accurate, for mep times used the tms_mep_max_latency table
%	slope
%	s50
%	mep_min
%	mep_max
%	slope_ci_1
%	slope_ci_2
%	s50_ci_1
%	s50_ci_2
%	mep_min_ci_1
%	mep_min_ci_2
%	mep_max_ci_1
%	mep_max_ci_2
%	r_sq
% auc
% auc_mean_values
% auc_stim_levels
% stimulator_mode
% analyzed_by
% analyzed_when
% last_update

data_tbl = table();

qry_str = sprintf(['select * ' ...
		'from tms_rc_measures ' ...
		'where subject = ''%s'' and ' ...
		'side = ''%s'' and ' ...
		'muscle = ''%s'' and ' ...
		'mep_method = ''%s'' ' ], subject, side, muscle, mep_method);

if ~isempty(session)
	qry_str = sprintf('%s and session = ''%s'' ', qry_str, session);
end
switch normed_or_not
	case 'norm'
		qry_str = sprintf('%s and norm_factor > 1 ', qry_str);
	case 'not_norm'
		qry_str = sprintf('%s and norm_factor = 1 ', qry_str);
	otherwise
		error('unknown normed_or_not value: %s', normed_or_not)
end

% open connection to database
dbparams = get_db_login_params('tdcs_vgait');

try
	conn = dbConnect(dbparams.dbname, dbparams.user, dbparams.password, dbparams.serveraddr);
catch
	warning('could not connect to database')
	return
end

% db_data_cell_array = conn.dbSearch('tms_rc_measures', var_list, 'subject', subject, ...
% 		'session', session, 'side', side, 'muscle', muscle, ...
% 		'mep_method', mep_method);
db_data_cell_array = conn.dbQuery(qry_str);
% close the database
conn.dbClose()

if isempty(db_data_cell_array)
	return
end

var_list = {'id', 'subject', 'session', 'side', 'muscle', 'mep_method', ...
				'norm_factor', 'mep_beg_t', 'mep_end_t', 'slope', 's50', ...
				'mep_max', 'mep_min', 'slope_ci_1', 'slope_ci_2', 's50_ci_1', 's50_ci_2', ...
				'mep_max_ci_1', 'mep_max_ci_2', 'mep_min_ci_1', 'mep_min_ci_2', 'r_sq', ...
				'auc', 'auc_mean_values', 'auc_stim_levels', 'stimulator_mode', ...
				'analyzed_by', 'analyzed_when', 'last_update'};

data_tbl = cell2table(db_data_cell_array, 'VariableNames', var_list);
return

end % get_rc_data_from_db
