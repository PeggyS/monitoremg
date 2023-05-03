function j_now_selected_rows = get_table_selected_rows(uitbl)
% selected table rows are 0 indexed.
jUIScrollPane = findjobj(uitbl);
jUITable = jUIScrollPane.getViewport.getView;
j_now_selected_rows = jUITable.getSelectedRows;