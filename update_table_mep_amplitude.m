function update_table_mep_amplitude(app, row)


if app.CheckBoxSici.Value == true % doing sici
	isi_col = contains(app.h_uitable.ColumnName, '>ISI<');
	% if ISI > 0, shift the data by ISI ms
	isi_ms = app.h_uitable.Data{row, isi_col};
	st_col = find(contains(app.h_uitable.ColumnName, '>Type<'));
	stim_type = app.h_uitable.Data{row, st_col}; %#ok<FNDSB>

	isi_shift_pts = 0;
	if isi_ms > 0 && ~strcmp(stim_type, 'Test Stim')
		% sici & icf
		isi_shift_pts = round(app.params.sampFreq * isi_ms / 1000);
	elseif isi_ms > 0 && strcmp(stim_type, 'Test Stim')
		% test stim: check which stimulator has the test stim
		bistim_col = find(contains(app.h_uitable.ColumnName, '>BiStim<'));
		if h_tbl.Data{new_row, bistim_col} > 0 %#ok<FNDSB> 
			% TS is in the bistim. Use the isi delay
			isi_shift_pts = round(app.params.sampFreq * isi_ms / 1000);
		end
	end
elseif app.CheckBoxRc.Value == true % doing rc
	isi_shift_pts = 0;
end


emg.XData = app.h_emg_line.XData;

% y data shifted in time if doing sici
tmp_data = app.emg_data(row, app.emg_data_num_vals_ignore+1:end);
emg.YData = [tmp_data(isi_shift_pts+1:end) nan(1,isi_shift_pts)];

% mep segment between start and end times
latency_col = contains(app.h_uitable.ColumnName, '>latency<');
mep_end_col = contains(app.h_uitable.ColumnName, '>end<');
mep_start_time = app.h_uitable.Data{row, latency_col};
mep_end_time = app.h_uitable.Data{row, mep_end_col};
mep_seg = emg.YData(emg.XData >= mep_start_time & emg.XData <= mep_end_time);
mep_val = round(max(mep_seg) - min(mep_seg)); % 2022-07-22 added round

% if needed, subtract the pre stim emg
if app.SubtractPreEMGppButton.Value 
	% compute the pre-stim emg
	% 		emg.YData = app.emg_data(row_cnt, app.emg_data_num_vals_ignore:end);
	pre_stim_val = compute_pre_stim_emg_value(app, emg);
	mep_val = round(mep_val - pre_stim_val); % 2022-07-22 added round
end

% update the table
mep_ampl_col = find(contains(app.h_uitable.ColumnName, '>MEPAmpl<'));
if app.h_uitable.Data{row, mep_ampl_col} ~= mep_val
	app.h_uitable.Data{row, mep_ampl_col} = mep_val;
end

return
end