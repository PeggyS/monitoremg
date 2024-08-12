function db_info = get_mep_max_latency_data_from_db(app, subject, session, side, muscle)
db_info = [];

% database query string
qry_str = sprintf(['select * ' ...
		'from tms_mep_max_latency ' ...
		'where subject = ''%s'' and ' ...
		'session = ''%s'' and ' ...
		'side = ''%s'' and ' ...
		'muscle = ''%s'' '], subject, session, side, muscle);

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
% effective_stimulator_output
% is_eff_so_max_stim
% num_samples
% num_meps
% mep_mean_latency
% num_mep_latencies_manually_adjusted
% mep_mean_end_time
% num_mep_end_times_manually_adjusted
% mep_mean_amplitude
% num_samples_with_comments
% num_sd
% e_stim_m_max
% did_rc_plateau
% analyzed_by
% analyzed_when
% verified_by
% verfied_when
% comments
% last_update
if ~isempty(qry_data_cell_array)
	% parse the data into db_info struct
	db_info.id = qry_data_cell_array{1};
	db_info.subject = qry_data_cell_array{2};
	db_info.session = qry_data_cell_array{3};
	db_info.side = qry_data_cell_array{4};
	db_info.muscle = qry_data_cell_array{5};
	db_info.effective_stimulator_output = qry_data_cell_array{6};
	db_info.is_eff_so_max_stim = qry_data_cell_array{7};
	db_info.num_samples = qry_data_cell_array{8};
	db_info.num_meps = qry_data_cell_array{9};
	db_info.mep_mean_latency = qry_data_cell_array{10};
	db_info.num_mep_latencies_manually_adjusted = qry_data_cell_array{11};
	db_info.mep_mean_end_time = qry_data_cell_array{12};
	db_info.num_mep_end_times_manually_adjusted = qry_data_cell_array{13};
	db_info.mep_mean_amplitude = qry_data_cell_array{14};
	db_info.num_samples_with_comments = qry_data_cell_array{15};
	db_info.num_sd = qry_data_cell_array{16};
	db_info.e_stim_m_max = qry_data_cell_array{17};
	db_info.did_rc_plateau = qry_data_cell_array{18};
	db_info.analyzed_by = qry_data_cell_array{19};
	db_info.analyzed_when = qry_data_cell_array{20};
	db_info.verified_by = qry_data_cell_array{21};
	db_info.verified_when = qry_data_cell_array{22};
	db_info.comments = qry_data_cell_array{23};
	db_info.last_update = qry_data_cell_array{24};
else
	db_info = [];
end

return
end