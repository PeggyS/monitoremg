function save_and_close_rc(source, event, app)

if isempty(app.SaveLocationEditField.Value)
	app.SaveLocationEditField.Value = pwd;
end

% save the data
filename = [app.SaveLocationEditField.Value '/' app.EditFieldFilenameprefix.Value ...
				strrep(app.rc_axes.Title.String, ' ', '_') ...
					'_rc_datapoints.csv'];
if exist(filename, 'file')
	filename = strrep(filename, '.csv', [datestr(now, '_yyyymmdd_HH:MM:SS') '.csv']);
end
save_rc_table(app.rc_axes.UserData, filename)
% and rc_fit_info
if isfield(app.rc_fit_info, 'mepMethod')
	fileName = [app.SaveLocationEditField.Value '/' app.EditFieldFilenameprefix.Value ...
				strrep(app.rc_axes.Title.String, ' ', '_') ...
				'_fit_info.txt'];
	if exist(filename, 'file')
		filename = strrep(filename, '.txt', [datestr(now, '_yyyymmdd_HH:MM:SS') '.txt']);
	end
	write_fit_info(fileName, app.rc_fit_info)
end

if strcmp(source.Tag, 'pushbutton')  % don't delete the pushbutton
	return
end

% delete the figure
delete(source)

% change checkbox
app.CheckBoxRecruitCurve.Value = 0;

return