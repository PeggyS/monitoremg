function update_initials_and_date(~, ~, app)
% update the initials and date of analysis to now and the current analyzer

app.h_edit_mep_done_by.String = upper(app.user_initials);
app.h_edit_mep_done_when.String = datestr(now, 'yyyy-mm-dd HH:MM:SS');

return
end