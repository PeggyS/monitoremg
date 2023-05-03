function select_table_rows(uitbl, j_now_selected_rows)
% j_now_selected_rows is zero indexed

jUIScrollPane = findjobj(uitbl);
jUITable = jUIScrollPane.getViewport.getView;
for r_cnt = 1:length(j_now_selected_rows)
	jUITable.changeSelection(j_now_selected_rows(r_cnt),0, true, false);
end