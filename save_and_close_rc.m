function save_and_close_rc(source, event, app)

% save the data
save_rc_table(app.rc_axes.UserData, 'test')
% and rc_fit_info
if isfield(app.rc_fit_info, 'mepMethod')
	fileName = 'test_fit_info.txt';
	write_fit_info(fileName, app.rc_fit_info)
end

% delete the figure
delete(source)

% change checkbox
app.CheckBoxRecruitCurve.Value = 0;

return