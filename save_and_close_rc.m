function save_and_close_rc(source, event, app)

% save the data
filename = [app.SaveLocationEditField.Value '/' app.EditFieldFilenameprefix.Value ...
				strrep(app.rc_axes.Title.String, ' ', '_') ...
					'_rc_datapoints.csv'];
save_rc_table(app.rc_axes.UserData, filename)
% and rc_fit_info
if isfield(app.rc_fit_info, 'mepMethod')
	fileName = [app.SaveLocationEditField.Value '/' app.EditFieldFilenameprefix.Value ...
				strrep(app.rc_axes.Title.String, ' ', '_') ...
				'_fit_info.txt'];
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