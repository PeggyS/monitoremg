function auto_adjust_mep_beg_end(src, evt, app)
% to reduce button clicking, automate clicking the 4 buttons to adjust mep beg and end lines

% keyboard

% select mep rows for this stim value
pushbutton_select_meps(src, evt, app)

% get the currently selected table rows
jUIScrollPane = findjobj(app.h_uitable);
jUITable = jUIScrollPane.getViewport.getView;
j_now_selected_rows = jUITable.getSelectedRows; % zero indexed
if isempty(j_now_selected_rows)
	disp('no table rows selected.')
	beep
	return
end

% toggle the current rows off
for r_cnt = 1:length(j_now_selected_rows)
	row = j_now_selected_rows(r_cnt);
	col = 1;
	% toggle the row
	jUITable.changeSelection(row,col-1, true, false);
end

pause_time = 0.2;
pause(pause_time*2)
% select each row individually
for r_cnt = 1:length(j_now_selected_rows)
	row = j_now_selected_rows(r_cnt);
	col = 1;
	% toggle the row on
	jUITable.changeSelection(row,col-1, true, false);
	pause(pause_time)

	% move mep beg and end lines using buttons
	pushbutton_adj_mep_beg(src, evt, app)
 	pause(pause_time)
	pushbutton_adj_mep_beg_old_method(src, evt, app)
 	pause(pause_time)
	pushbutton_adj_mep_end(src, evt, app)
 	pause(pause_time)
	pushbutton_adj_mep_end_old_method(src, evt, app)
 	pause(pause_time)

	% toggle the row off
	jUITable.changeSelection(row,col-1, true, false);
	pause(pause_time)
end

% toggle back on the 1st row
jUITable.changeSelection(j_now_selected_rows(1),col-1, true, false);

end % function