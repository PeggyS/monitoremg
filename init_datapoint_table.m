function init_datapoint_table(app, tbl)

% col 2 = Use = logical
tbl.Use = logical(tbl.Use);

% ======= rc or sici fig ===========
if app.ButtonRc.Value == 1
	headers = {'Epoch', 'Use', ...
           '<html><center>MagStim<br />Setting</center></html>', ...
           '<html><center>MEPAmpl<br />uVPp</center></html>', ...
           '<html><center>PreStimEmg<br />100ms</center></html>', ...
           '<html><center>MonitorEMG<br />val</center></html>', ...
           '<html><center>Goal<br />EMG</center></html>', ...
           '<html><center>Goal<br />Min</center></html>', ...
           '<html><center>Goal<br />Max</center></html>'};
	  colwidths = {40, 30, 50, 'auto', 'auto', 'auto', 60, 50, 50};
	  coledit = [false, true, true, false, false, false, false, false, false];
else
	headers = {'Epoch', 'Use', ...
           '<html><center>MagStim<br />Setting</center></html>', ...
           '<html><center>MEPAmpl<br />uVPp</center></html>', ...
		   '<html><center>Stim<br />Type</center></html>', ...
           '<html><center>PreStimEmg<br />100ms</center></html>', ...
           '<html><center>MonitorEMG<br />val</center></html>', ...
           '<html><center>Goal<br />EMG</center></html>', ...
           '<html><center>Goal<br />Min</center></html>', ...
           '<html><center>Goal<br />Max</center></html>'};
	colwidths = {40, 30, 50, 50, 'auto', 'auto', 'auto', 60, 50, 50};
	  coledit = [false, true, true, true, false, false, false, false, false, false];
end


% 
app.h_uitable.Data = table2cell(tbl);
app.h_uitable.ColumnName = headers';
app.h_uitable.ColumnWidth = colwidths;
app.h_uitable.ColumnEditable = coledit;
app.h_uitable.CellEditCallback = {'rc_dp_tbl_edit_callback', app};
app.h_uitable.CellSelectionCallback = {'rc_dp_tbl_select_callback', app};

% keyboard


% m = numeric handle to uitable
% m = uitable(...); 
% jUIScrollPane = findjobj(m);
% jUITable = jUIScrollPane.getViewport.getView;
% jUITable.changeSelection(row-1,col-1, false, false);
% subtract 1 from row and col you want selected
% the last two arguments do the following:
% false, false: Clear the previous selection and ensure the new cell is selected.
% false, true: Extend the previous selection (select a range of cells).
% true, false: Toggle selection
% true, true: Apply the selection state of the anchor to all cells between it and the specified cell.