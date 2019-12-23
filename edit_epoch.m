function edit_epoch(source, event, app)

new_row = str2double(source.String);
update_review_emg_data_line(app, app.h_uitable, new_row)

return