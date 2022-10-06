function init_datapoint_table(app, tbl)
% fill in the datapoint table with info in tbl (the rc data points)
% tbl cols: Epoch,Use,MagStim_Setting,MEPAmpl_uVPp,PreStimEmg_100ms,MonitorEMGval,GoalEMG,GoalEMGmin,GoalEMGmax

% if the tbl is empty, then data table was missing from data & analysis folders
if isempty(tbl)
	% create the table
	num_rows = size(app.emg_data,1);
	tbl = table('Size', [num_rows, 13], ...
		'VariableTypes', {'double', 'logical', 'double', 'double', 'double', 'double', ...
		'double', 'double', 'double', 'double', 'double', 'double', 'double'}, ...
		'VariableNames', {'Epoch', 'Use', 'MagStim_Setting', 'BiStim_Setting', 'ISI_ms', ...
		'Effective_SO', 'MEPAmpl_uVPp', 'MEPAUC_uV_ms', ...
		'PreStimEmg_100ms', 'MonitorEMGval', 'GoalEMG', 'GoalEMGmin', 'GoalEMGmax'});
	tbl.Epoch = (1:num_rows)';
	tbl.Use = true(num_rows, 1);
	tbl.MagStim_Setting = nan(num_rows, 1);
	tbl.BiStim_Setting = nan(num_rows, 1);
	tbl.ISI_ms = nan(num_rows, 1);
	tbl.Effective_SO = nan(num_rows, 1);
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

next_col_num = 4; % column where to add additional variables

% if there is no Bistim col, add it
if ~contains(tbl.Properties.VariableNames, 'BiStim_Setting')
	disp('Adding Bistim column to datapoint table')
	n_cols = width(tbl);
	tbl = [tbl(:,1:next_col_num-1) array2table(zeros(height(tbl),1)) tbl(:,next_col_num:n_cols)];
	tbl.Properties.VariableNames{next_col_num} = 'BiStim_Setting';
	next_col_num = next_col_num + 1;

	if app.CheckBoxSici.Value == 1
		stim_mode = 'SICI/ICF';
	else
		if contains(app.h_stim_setup_text.String, 'bistim', 'IgnoreCase', true)
			% ask the user if this was simultaneous discharge or not
			q_str = 'Was this single pulse, Simultaneous Discharge of the stimulator, or SICI/ICF?';
			tlt = 'Stimulator Mode';
			app.ReviewEMGRCUIFigure.WindowStyle = 'alwaysontop';
			stim_mode = uiconfirm(app.ReviewEMGRCUIFigure, q_str, tlt, ...
				'Options', {'Single Pulse', 'Simultaneous Discharge'}, ...
				'DefaultOption', 2);
			app.ReviewEMGRCUIFigure.WindowStyle = 'normal';
		else
			stim_mode = 'Single Pulse';
		end
	end

	disp(['stimulator mode: ' stim_mode])
	switch stim_mode
		case 'Single Pulse'
			tbl.BiStim_Setting = zeros(height(tbl), 1);
		case 'Simultaneous Discharge'
			tbl.BiStim_Setting = tbl.MagStim_Setting;
		case 'SICI/ICF'
			tbl.BiStim_Setting = nan(height(tbl), 1);
			st_ind = find(contains(tbl.Properties.VariableNames, 'Stim_Type', 'IgnoreCase', true), 1);
			if isempty(st_ind)
				% 2nd chance: look for old variable name
				st_ind = find(contains(tbl.Properties.VariableNames, 'Sici_or_icf_or_ts', 'IgnoreCase', true), 1);
				if isempty(st_ind)
					keyboard
				end
				% change the variable name
				tbl.Properties.VariableNames{st_ind} = 'Stim_Type';
			end
			if ~isempty(st_ind)
				test_stim_msk = contains(lower(tbl.Stim_Type), 'test stim');
				test_stim_val = unique(tbl.MagStim_Setting(test_stim_msk));
				if length(test_stim_val) > 1 || test_stim_val == 0
					% ask the user what the test stim value was
					q_str = 'What was the Test Stimulus value?';
					dlg_ans = inputdlg( q_str );
					test_stim_val = str2double(dlg_ans);

					% put this in the bistim_setting
					tbl.BiStim_Setting(test_stim_msk) = test_stim_val * ones(size(tbl.BiStim_Setting(test_stim_msk)));
					% ask what the ISI was - save this for later (when adding the isi column)
					q_str = 'What was the Test Stimulus Interstimulus Interval?';
					dlg_ans = inputdlg( q_str );
					test_stim_isi_val = str2double(dlg_ans);
				else
					tbl.BiStim_Setting(test_stim_msk) = zeros(size(tbl.BiStim_Setting(test_stim_msk)));
				end

				% fill the test stim in the bistim col
				tbl.BiStim_Setting(~test_stim_msk) = test_stim_val * ones(size(tbl.BiStim_Setting(~test_stim_msk)));

			end
	end % switch stim_mode
end % if there is no Bistim col

% if there is no ISI col, add it
if ~contains(tbl.Properties.VariableNames, 'ISI_ms')
	disp('Datapoint table: adding ISI...')
	n_cols = width(tbl);
	tbl = [tbl(:,1:next_col_num-1) array2table(nan(height(tbl),1)) tbl(:,next_col_num:n_cols)];
	tbl.Properties.VariableNames{next_col_num} = 'ISI_ms';
	next_col_num = next_col_num + 1;
end
% if ISI are nan guess them
if any(isnan(tbl.ISI_ms))
	disp('Datapoint table: guessing ISI...')
	st_ind = find(contains(tbl.Properties.VariableNames, 'Stim_Type', 'IgnoreCase', true));
	if isempty(st_ind)
		% look for 'Sici_or_icf_or_ts'
		st_ind = find(contains(tbl.Properties.VariableNames, 'Sici_or_icf_or_ts', 'IgnoreCase', true));
		if ~isempty(st_ind)
			tbl.Properties.VariableNames{st_ind} = 'Stim_Type';
		end

	end
	if ~isempty(st_ind) % if there should be different isi values for sici and icf
		for row_cnt = 1:height(tbl)
			stim_type = tbl{row_cnt, st_ind};
			switch lower(stim_type{:})
				case 'test stim'
					if exist('test_stim_isi_val', 'var')
						isi = test_stim_isi_val;
					else
						isi = 0;
					end
				case 'sici'
					isi = 2;
				case 'icf'
					isi = 10;
				otherwise
					isi = 0;
					beep
					disp(['init_datapoint_table.m: unknown stim type: ' stim_type])
			end
			tbl.ISI_ms(row_cnt) = isi;
		end
	else
		% not sici icf, check stim_mode
		if ~exist('stim_mode', 'var')
			beep
			disp('init_datapoint_table: stim_mode should have been created!')
			disp('setting all ISI to zero')
			tbl.ISI_ms = zeros(height(tbl), 1);
		else
			switch stim_mode
				case 'Single Pulse'
					tbl.ISI_ms = ones(height(tbl), 1);
				case 'Simultaneous Discharge'
					tbl.ISI_ms = zeros(height(tbl), 1);
			end
		end
	end
end

% for rc, if there is no Effective SO col, add it
if ~app.CheckBoxSici.Value == 1
	if ~contains(tbl.Properties.VariableNames, 'Effective_SO')
		disp('Datapoint table: Adding Effective Stimulator Output ...')
		n_cols = width(tbl);
		tbl = [tbl(:,1:next_col_num-1) array2table(nan(height(tbl),1)) tbl(:,next_col_num:n_cols)];
		tbl.Properties.VariableNames{next_col_num} = 'Effective_SO';
		next_col_num = next_col_num + 1;
	end
	% if effective so are nan compute them
	if any(isnan(tbl.Effective_SO))
		for row_cnt = 1:height(tbl)
			tbl.Effective_SO(row_cnt) = compute_effective_so(tbl.MagStim_Setting(row_cnt), ...
				tbl.BiStim_Setting(row_cnt), tbl.ISI_ms(row_cnt), app.h_stim_setup_text.String);
		end
	end
end


% if there is no MEPAUC col, add it
if ~contains(tbl.Properties.VariableNames, 'MEPAUC')
	disp('Computing MEP AUC...')
	n_cols = width(tbl);
	% put it after the MEPAmpl_uVPp col
	next_col_num = find(contains(tbl.Properties.VariableNames, 'MEPAmpl_uVPp')) + 1;
	tbl = [tbl(:,1:next_col_num-1) array2table(nan(height(tbl),1)) tbl(:,next_col_num:n_cols)];
	tbl.Properties.VariableNames{next_col_num} = 'MEPAUC_uV_ms';
end

% if MEPAUCs are nan, compute them
if any(isnan(tbl.MEPAUC_uV_ms))
	% compute all the MEPAUCs and recompute MEPAmpl_uVPp using the current
	% mep_beg_t and mep_end_t
	
	emg.XData = app.h_emg_line.XData;
	for row_cnt = 1:height(tbl)

		% mep beg & end times 
		mep_start_time = app.h_t_min_line.XData(1);
		mep_end_time = app.h_t_max_line.XData(1);

		% if SICI/ICF and ISI > 0, shift the data by ISI ms
		if app.CheckBoxSici.Value == 1 && tbl.ISI_ms(row_cnt) > 0
			shift_ISI = round(app.params.sampFreq * tbl.ISI_ms(row_cnt) / 1000);
		else
			shift_ISI = 0;
		end
		emg.YData = app.emg_data(row_cnt, app.emg_data_num_vals_ignore+1:end);
		emg.YData = [emg.YData(shift_ISI+1:end) nan(1,shift_ISI)];
		
		mep_seg = emg.YData(emg.XData >= mep_start_time & emg.XData <= mep_end_time);
		mep_val = max(mep_seg) - min(mep_seg);
		
		if app.SubtractPreEMGppButton.Value % subtract the pre stim emg
			% compute the pre-stim emg
			pre_stim_val = compute_pre_stim_emg_value(app, emg);
			mep_val = mep_val - pre_stim_val;
		end
		tbl.MEPAmpl_uVPp(row_cnt) = round(mep_val);
	
		% update emg auc patch
		[vertices, ~] = compute_patch(mep_start_time, mep_end_time, emg, 0);
		% auc
		auc = compute_auc(vertices);
		tbl.MEPAUC_uV_ms(row_cnt) = round(auc);
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
		tbl.PreStimEmg_100ms(row_cnt) = round(compute_pre_stim_emg_value(app, emg), 2);
	end
end

% % if mep ampl is nan, compute it
% if any(isnan(tbl.MEPAmpl_uVPp))
% 	disp('Computing MEP Ampl...')
% 	emg.XData = app.h_emg_line.XData;
% 	for row_cnt  = 1:height(tbl)
% 		emg.YData = app.emg_data(row_cnt, app.emg_data_num_vals_ignore+1:end);
% 		mep_seg = emg.YData(emg.XData >= str2double(app.h_edit_mep_begin.String) & ...
% 			emg.XData <= str2double(app.h_edit_mep_end.String));
% 		mep_val = max(mep_seg) - min(mep_seg);
% 		tbl.MEPAmpl_uVPp(row_cnt) = round(mep_val);
% % 		tbl.MEPAmpl_uVPp(row_cnt) = max(emg.YData(emg.XData > str2double(app.h_edit_mep_begin.String) & ...
% % 			emg.XData < str2double(app.h_edit_mep_end.String))) ...
% % 			- min(emg.YData(emg.XData > str2double(app.h_edit_mep_begin.String) & ...
% % 			emg.XData < str2double(app.h_edit_mep_end.String))) ;
% 		
% 	end
% end

% if monitorEMG or goal cols are missing, add them MonitorEMGval,GoalEMG,GoalEMGmin,GoalEMGmax
if ~any(contains(tbl.Properties.VariableNames, 'MonitorEMGval') | ...
		contains(tbl.Properties.VariableNames, 'MonitorEMG_val'))
	tbl.MonitorEMGval = nan(height(tbl), 1);
end
if ~any(contains(tbl.Properties.VariableNames, 'GoalEMG') | ...
		contains(tbl.Properties.VariableNames, 'Goal_EMG'))
	tbl.GoalEMG = nan(height(tbl), 1);
end
if ~any(contains(tbl.Properties.VariableNames, 'GoalEMGmin') | ...
		contains(tbl.Properties.VariableNames, 'Goal_Min'))
	tbl.GoalEMGmin = nan(height(tbl), 1);
end
if ~any(contains(tbl.Properties.VariableNames, 'GoalEMGmax') | ...
		contains(tbl.Properties.VariableNames, 'Goal_Max'))
	tbl.GoalEMGmax = nan(height(tbl), 1);
end

% ======= rc or sici fig ===========
if app.CheckBoxSici.Value == 1
	headers = {'Epoch', 'Use', ...
		'<html><center>MagStim<br />Setting</center></html>', ...
		'<html><center>BiStim<br />Setting</center></html>', ...
		'<html><center>ISI<br />ms</center></html>', ...
		'<html><center>Stim<br />Type</center></html>', ...
		'<html><center>MEPAmpl<br />uVPp</center></html>', ...
		'<html><center>MEPAUC<br />uV*ms</center></html>', ...
		'<html><center>PreStimEmg<br />100ms</center></html>', ...
		'<html><center>MonitorEMG<br />val</center></html>', ...
		'<html><center>Goal<br />EMG</center></html>', ...
		'<html><center>Goal<br />Min</center></html>', ...
		'<html><center>Goal<br />Max</center></html>'};
	colwidths = {40, 30, 50, 50, 30, 60, 50, 50, 'auto', 'auto', 60, 50, 50};
	coledit = [false, true, true, true, true, false, false, true, false, false, false, false, false];

	% send the test stim to the sici icf window
	if ~exist('test_stim_val', 'var')
		test_stim_val = mode(tbl.BiStim_Setting(contains(tbl.Stim_Type, 'sici', 'IgnoreCase', true)));
	end
	cs_stim_val = mode(tbl.MagStim_Setting(contains(tbl.Stim_Type, 'sici', 'IgnoreCase', true)));
	app.sici_ui.ts.String = num2str(test_stim_val);
	app.sici_ui.cs.String = num2str(cs_stim_val);
else % rc or data only / average
	headers = {'Epoch', 'Use', ...
		'<html><center>MagStim<br />Setting</center></html>', ...
		'<html><center>BiStim<br />Setting</center></html>', ...
		'<html><center>ISI<br />ms</center></html>', ...
		'<html><center>Effective<br />SO</center></html>', ...
		'<html><center>MEPAmpl<br />uVPp</center></html>', ...
		'<html><center>MEPAUC<br />uV*ms</center></html>', ...
		'<html><center>PreStimEmg<br />100ms</center></html>', ...
		'<html><center>MonitorEMG<br />val</center></html>', ...
		'<html><center>Goal<br />EMG</center></html>', ...
		'<html><center>Goal<br />Min</center></html>', ...
		'<html><center>Goal<br />Max</center></html>'};
	colwidths = {40, 30, 50, 50, 30, 50, 60, 50, 'auto', 'auto', 60, 50, 50};
	coledit = [false, true, true, true, true, false, false, false, false, false, false, false, false];
end


% round mep p2p and auc values
tbl(:,'MEPAmpl_uVPp') = table(round(table2array(tbl(:,'MEPAmpl_uVPp'))));
tbl(:,'MEPAUC_uV_ms' ) = table(round(table2array(tbl(:,'MEPAUC_uV_ms'))));
tbl(:,'PreStimEmg_100ms' ) = table(round(table2array(tbl(:,'PreStimEmg_100ms'))));

app.h_uitable.Data = table2cell(tbl);
app.h_uitable.ColumnName = headers';
app.h_uitable.ColumnWidth = colwidths;
app.h_uitable.ColumnEditable = coledit;
app.h_uitable.CellEditCallback = {'rc_dp_tbl_edit_callback', app};
app.h_uitable.CellSelectionCallback = {'rc_dp_tbl_select_callback', app};

