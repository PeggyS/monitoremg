function db_tbl = get_sici_icf_data_from_db(app, subject, session, side, muscle, stim_type)

if ~exist('stim_type', 'var') || isempty(stim_type)
	stim_type = '%';
end

% database query string
qry_str = sprintf(['select * ' ...
		'from tms_sici_icf ' ...
		'where subject = ''%s'' and ' ...
		'session = ''%s'' and ' ...
		'side = ''%s'' and ' ...
		'muscle = ''%s'' and ' ...
		'stim_type like ''%s'' '], subject, session, side, muscle, stim_type);

% database parameters
dbparams = get_db_login_params(app.db_str);

% open connection to database
try
	conn = dbConnect(dbparams.dbname, dbparams.user, dbparams.password, dbparams.serveraddr);
catch ME
	disp('could not connect to database')
	rethrow(ME)
end
% query
qry_data_cell_array = conn.dbQuery(qry_str);
% close the database
conn.dbClose()

% columns in the database
% id
% subject
% session
% side
% muscle
% magstim_setting
% bistim_setting
% isi_ms
% stim_type
% num_samples
% num_meps
% mep_latency_mean
% mep_latency_sd
% mep_end_time_mean
% mep_end_time_sd
% mep_amplitude_mean
% mep_amplitude_sd
% mep_ampl_98pct_ci_1
% mep_ampl_98pct_ci_2
% num_samples_with_comments
% num_sd
% analyzed_by
% analyzed_when
% verified_by
% verfied_when
% comments
% last_update
if ~isempty(qry_data_cell_array)
	db_tbl = cell2table(qry_data_cell_array, 'VariableNames', ...
		{'id', ...
		'subject', ...
		'session', ...
		'side', ...
		'muscle', ...
		'magstim_setting', ...
		'bistim_setting', ...
		'isi_ms', ...
		'stim_type', ...
		'num_samples', ...
		'num_meps', ...
		'mep_latency_mean', ...
		'mep_latency_sd', ...
		'num_mep_latencies_manually_adjusted', ...
		'mep_end_time_mean', ...
		'mep_end_time_sd', ...
		'num_mep_end_times_manually_adjusted', ...
		'mep_amplitude_mean', ...
		'mep_amplitude_sd', ...
		'mep_ampl_98pct_ci_1', ...
		'mep_ampl_98pct_ci_2', ...
		'num_samples_with_comments', ...
		'num_sd', ...
		'analyzed_by', ...
		'analyzed_when', ...
		'verified_by', ...
		'verified_when', ...
		'comments', ...
		'last_update'}	);
else
	db_tbl = [];
end

return
end