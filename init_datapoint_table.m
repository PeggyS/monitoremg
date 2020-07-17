function init_datapoint_table(app, tbl)
% fill in the datapoint table with info in tbl (the rc data points)
% tbl cols: Epoch,Use,MagStim_Setting,MEPAmpl_uVPp,PreStimEmg_100ms,MonitorEMGval,GoalEMG,GoalEMGmin,GoalEMGmax

% if the tbl is empty, then data table was missing from data & analysis folders
if isempty(tbl)
	% create the table
	num_rows = size(app.emg_data,1);
	tbl = table('Size', [num_rows, 10], ...
		'VariableTypes', {'double', 'logical', 'double', 'double', 'double', ...
							'double', 'double', 'double', 'double', 'double'}, ...
		'VariableNames', {'Epoch', 'Use', 'MagStim_Setting', 'MEPAmpl_uVPp', 'MEPAUC_uV_ms', ...
							'PreStimEmg_100ms', 'MonitorEMGval', 'GoalEMG', 'GoalEMGmin', 'GoalEMGmax'});
 	tbl.Epoch = (1:num_rows)';
	tbl.Use = true(num_rows, 1);
	tbl.MagStim_Setting = nan(num_rows, 1);
	tbl.MEPAmpl_uVPp = nan(num_rows, 1);
	tbl.MEPAUC_uV_ms = nan(num_rows, 1);
	tbl.PreStimEmg_100ms = nan(num_rows, 1);
	tbl.MonitorEMGval = nan(num_rows, 1);
	tbl.GoalEMG = nan(num_rows, 1);
	tbl.GoalEMGmin = nan(num_rows, 1);
	tbl.GoalEMGmax = nan(num_rows, 1);
end

% col 2 = Use = logical
tbl.Use = logical(tbl.Use);

% magstim setting & use value if it's in the emg_data
% Depending upon when the data was recorded, there will be either 1 or 2
% values to ignore at the beginning of each row of emg data. If there is 1
% value to ignore, then that is the magstim value. If there are 2 values to
% ignore, then the 1st is the Use value & second is magstim value.
if any(isnan(tbl.Use))
	% use the first col in emg_data as the use value
	if app.emg_data_num_vals_ignore > 1
		tbl.Use = app.emg_data(:, 1);
	end
end
if any(isnan(tbl.MagStim_Setting))
	magstim_col = app.emg_data_num_vals_ignore;
	tbl.MagStim_Setting = app.emg_data(:, magstim_col);
end

% if there is no MEPAUC col, add it
if ~contains(tbl.Properties.VariableNames, 'MEPAUC')
	disp('Computing MEP AUC...')
	n_cols = width(tbl);
	tbl = [tbl(:,1:4) array2table(nan(height(tbl),1)) tbl(:,5:n_cols)];
	tbl.Properties.VariableNames{5} = 'MEPAUC_uV_ms';
end
% if MEPAUCs are nan, compute them
if any(isnan(tbl.MEPAUC_uV_ms))
	% compute all the MEPAUCs
	emg.XData = app.h_emg_line.XData;
	for row_cnt = 1:height(tbl)
		% pre_stim_val = tbl.PreStimEmg_100ms(row_cnt);
		
		% update emg auc patch
		mep_start_time = app.h_t_min_line.XData(1);
		mep_end_time = app.h_t_max_line.XData(1);
		
		emg.YData = app.emg_data(row_cnt, app.emg_data_num_vals_ignore+1:end);
		[vertices, ~] = compute_patch(mep_start_time, mep_end_time, emg, 0);
		
		auc = compute_auc(vertices);
		tbl.MEPAUC_uV_ms(row_cnt) = auc;
	end
end

% if column PreStimEmg_100ms is missing, create it
if ~any(contains(tbl.Properties.VariableNames, 'PreStimEmg_100ms'))
	tbl.PreStimEmg_100ms = nan(height(tbl), 1);
end
% if prestim emg is nan, compute it
if any(isnan(tbl.PreStimEmg_100ms))
	disp('Computing Pre Stim EMG...')
	emg.XData = app.h_emg_line.XData;
	for row_cnt  = 1:height(tbl)
		emg.YData = app.emg_data(row_cnt, app.emg_data_num_vals_ignore+1:end);
		tbl.PreStimEmg_100ms(row_cnt) = compute_pre_stim_emg_value(app, emg);
	end
end

% if mep ampl is nan, compute it
if any(isnan(tbl.MEPAmpl_uVPp))
	disp('Computing MEP Ampl...')
	emg.XData = app.h_emg_line.XData;
	for row_cnt  = 1:height(tbl)
		emg.YData = app.emg_data(row_cnt, app.emg_data_num_vals_ignore+1:end);
		tbl.MEPAmpl_uVPp(row_cnt) = max(emg.YData(emg.XData > str2double(app.h_edit_mep_begin.String) & ...
													emg.XData < str2double(app.h_edit_mep_end.String))) ...
								- min(emg.YData(emg.XData > str2double(app.h_edit_mep_begin.String) & ...
													emg.XData < str2double(app.h_edit_mep_end.String))) ;
	end
end

% if monitorEMG or goal cols are missing, add them MonitorEMGval,GoalEMG,GoalEMGmin,GoalEMGmax
if ~any(contains(tbl.Properties.VariableNames, 'MonitorEMGval'))
	tbl.MonitorEMGval = nan(height(tbl), 1);
end
if ~any(contains(tbl.Properties.VariableNames, 'GoalEMG'))
	tbl.GoalEMG = nan(height(tbl), 1);
end
if ~any(contains(tbl.Properties.VariableNames, 'GoalEMGmin'))
	tbl.GoalEMGmin = nan(height(tbl), 1);
end
if ~any(contains(tbl.Properties.VariableNames, 'GoalEMGmax'))
	tbl.GoalEMGmax = nan(height(tbl), 1);
end

% ======= rc or sici fig ===========
if app.CheckBoxSici.Value == 1
	headers = {'Epoch', 'Use', ...
           '<html><center>MagStim<br />Setting</center></html>', ...
           '<html><center>MEPAmpl<br />uVPp</center></html>', ...
		   '<html><center>MEPAUC<br />uV*ms</center></html>', ...
		   '<html><center>Stim<br />Type</center></html>', ...
           '<html><center>PreStimEmg<br />100ms</center></html>', ...
           '<html><center>MonitorEMG<br />val</center></html>', ...
           '<html><center>Goal<br />EMG</center></html>', ...
           '<html><center>Goal<br />Min</center></html>', ...
           '<html><center>Goal<br />Max</center></html>'};
	colwidths = {40, 30, 50, 50, 50, 'auto', 'auto', 'auto', 60, 50, 50};
	  coledit = [false, true, true, true, true, false, false, false, false, false, false];
else % rc or data only / average
	headers = {'Epoch', 'Use', ...
           '<html><center>MagStim<br />Setting</center></html>', ...
           '<html><center>MEPAmpl<br />uVPp</center></html>', ...
		   '<html><center>MEPAUC<br />uV*ms</center></html>', ...
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