function save_and_close_rc(source, event, app)

% save the data
save_rc_table(app.rc_axes.UserData, 'test')

% delete the figure
delete(source)

% change checkbox
app.CheckBoxRecruitCurve.Value = 0;

return