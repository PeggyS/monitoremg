function update_rc_datapoint(rc_axes, table_row_num, mep_val)

h_line = find_rc_datapoint(rc_axes, table_row_num);

h_line.YData = mep_val;

rc_axes.UserData.MEPAmpl_uVPp(table_row_num) = mep_val;