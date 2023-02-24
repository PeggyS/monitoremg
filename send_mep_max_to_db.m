function send_mep_max_to_db(app)

% open connection to database
dbparams = get_db_login_params(app.db_str);

% see if this data is already in the database
subject = app.SubjectEditField_muscP.Value;
session = app.SessionEditField_muscP.Value;
side_muscle = app.MuscleEditField_muscP.Value;

split_cell = strsplit(side_muscle, '_');
side = split_cell{1};
muscle = split_cell{2};

db_info = get_mep_max_latency_data_from_db(app, subject, session, side, muscle);
if isempty(db_info)
	% not there, need to add the data
else
	% there is something there, need to update the data
end


try
	conn = dbConnect(dbparams.dbname, dbparams.user, dbparams.password, dbparams.serveraddr);
catch ME
	disp(ME)
	warning('could not connect to database')
	return
end


return
end