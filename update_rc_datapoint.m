function update_rc_datapoint(app, table_row_num, mep_val)

h_line = find_rc_datapoint(app.rc_axes, table_row_num);

h_line.YData = mep_val/str2double(app.rc_fit_ui.edNormFactor.String) ;

app.rc_axes.UserData.MEPAmpl_uVPp(table_row_num) = mep_val;