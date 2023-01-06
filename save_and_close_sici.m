function save_and_close_sici(source, event, app) %#ok<INUSL> 
try
	
	if ~isprop(app, 'SaveLocationEditField')
		[pname, ~, ~] = fileparts(app.EMGDataTxtEditField.Value);
		save_loc = pname;
		% if the current directory has '/data/' in it then change it
		% '/analysis/' to save the output there
		if contains(save_loc, [filesep 'data' filesep], 'IgnoreCase', true)
			save_loc = strrep(lower(save_loc), [filesep 'data' filesep], [filesep 'analysis' filesep]);
			% ask to create the folder if it doesn't exist
			if ~exist(save_loc, 'dir')
				ButtonName = questdlg(['Create new directory: ' save_loc ' ?'], ...
					'Create new directory', ...
					'Yes', 'No', 'Yes');
				if strcmp(ButtonName, 'Yes')
					[success, msg, msg_id] = mkdir(save_loc); %#ok<ASGLU> 
				else
					disp('Choose where to save output')
					save_loc = uigetdir();
				end
			end
		end
		fname_prefix = '';
	else
		if isempty(app.SaveLocationEditField.Value)
			app.SaveLocationEditField.Value = pwd;
			save_loc = pwd;
		else
			save_loc = app.SaveLocationEditField.Value;
		end
		fname_prefix = app.EditFieldFilenameprefix.Value;
	end
	
	% determine mep method
	[~, mep_method] = get_data_var_mep_method(app);
	
	% determine base filename for saving datapoints.csv & fitinfo.txt
	title_str = strrep(app.sici_axes.Title.String, ' ', '_');
	if contains(title_str, '.csv') % it's a file read in, no need to add prefix
		datapoint_fname = title_str;
		sici_info_fname = strrep(title_str, 'sici_datapoints.csv', 'sici_info.txt');
	else
		datapoint_fname = [save_loc filesep fname_prefix title_str '_sici_datapoints.csv'];
		sici_info_fname = [save_loc filesep fname_prefix title_str '_' mep_method '_sici_info.txt'];
	end
	
	% add norm or not norm to fit_info.txt
	if str2double(app.rc_fit_ui.edNormFactor.String) > 1
		sici_info_fname = strrep(sici_info_fname, 'info.txt', 'info_norm.txt');
	else
		sici_info_fname = strrep(sici_info_fname, 'info.txt', 'info_not_norm.txt');
	end
	
	[confirm_saving, datapoint_fname] = confirm_savename(datapoint_fname);
	
	
	if confirm_saving
		% save the data
		try
			save_rc_table(app.sici_axes.UserData, datapoint_fname)
		catch ME
			disp('did not save sici_datapoints')
			disp(ME)
		end
	end % confirmed saving
	
	if isfield(app.sici_info, 'ts_n')
		
		[confirm_saving, sici_info_fname] = confirm_savename(sici_info_fname);
		if confirm_saving
			% get the TS & CS values
			app.sici_info.ts_value = str2double(app.sici_ui.ts.String);
			app.sici_info.cs_value = str2double(app.sici_ui.cs.String);
			if isnan(app.sici_info.ts_value) || isnan(app.sici_info.cs_value)
				beep
				warning('Test stim and Conditioning stim values must be filled in before saving.')
				error('ts  and cs values are nan')
			end
			% ISIs from h_uitable
			if isprop(app, 'h_uitable')
				stim_type_col = find(contains(app.h_uitable.ColumnName, '>Stim<'));
				isi_col = contains(app.h_uitable.ColumnName, '>ISI<');
				stim_types = unique(app.h_uitable.Data(:,stim_type_col));
				for st_cnt = 1:length(stim_types)
					st = stim_types{st_cnt};
					row = find(contains(app.h_uitable.Data(:,stim_type_col), st), 1, 'first');
					isi = app.h_uitable.Data{row, isi_col};
					st = strrep(st, ' ', '_');
					app.sici_info.([lower(st) '_isi']) = isi;
				end
			else
				sici_tbl = app.sici_axes.UserData;
				stim_types = unique(sici_tbl.Stim_Type);
				for st_cnt = 1:length(stim_types)
					st = stim_types{st_cnt};
					row = find(contains(sici_tbl.Stim_Type, st), 1, 'first');
					isi = sici_tbl.ISI_ms(row);
					st = strrep(st, ' ', '_');
					app.sici_info.([lower(st) '_isi']) = isi;
				end
			end
			[~, app.sici_info.mepMethod] = get_data_var_mep_method(app);
			if isprop(app, 'rc_fit_ui')
				app.sici_info.mep_norm_factor = str2double(app.rc_fit_ui.edNormFactor.String); 
			end
			% for review_emg:
			if isprop(app, 'sici_ui') && isfield(app.sici_ui, 'ts_latency') && ...
					isfield(app.sici_ui.ts_latency.UserData, 'mep_beg_t')
				app.sici_info.ts_mep_beg_t = app.sici_ui.ts_latency.UserData.mep_beg_t;
				app.sici_info.ts_mep_end_t = app.sici_ui.ts_latency.UserData.mep_end_t;
				app.sici_info.ts_epochs_used = app.sici_ui.ts_latency.UserData.epochs_used;
				app.sici_info.ts_num_sd = app.sici_ui.ts_latency.UserData.num_sd;
			end
			if isprop(app, 'sici_ui') && isfield(app.sici_ui, 'sici_latency') && ...
					isfield(app.sici_ui.sici_latency.UserData, 'mep_beg_t')
				app.sici_info.sici_mep_beg_t = app.sici_ui.sici_latency.UserData.mep_beg_t;
				app.sici_info.sici_mep_end_t = app.sici_ui.sici_latency.UserData.mep_end_t;
				app.sici_info.sici_epochs_used = app.sici_ui.sici_latency.UserData.epochs_used;
				app.sici_info.sici_num_sd = app.sici_ui.sici_latency.UserData.num_sd;
			end
			if isprop(app, 'sici_ui') && isfield(app.sici_ui, 'icf_latency') && ...
					isfield(app.sici_ui.icf_latency.UserData, 'mep_beg_t')
				app.sici_info.icf_mep_beg_t = app.sici_ui.icf_latency.UserData.mep_beg_t;
				app.sici_info.icf_mep_end_t = app.sici_ui.icf_latency.UserData.mep_end_t;
				app.sici_info.icf_epochs_used = app.sici_ui.icf_latency.UserData.epochs_used;
				app.sici_info.icf_num_sd = app.sici_ui.icf_latency.UserData.num_sd;
			end
			if isprop(app, 'AnalyzedbyEditField')
				app.sici_info.analyzed_by = upper(app.user_initials);
				app.AnalyzedbyEditField.Value = upper(app.user_initials);
				app.sici_info.analyzed_when = datestr(now, 'yyyy-mm-dd HH:MM:SS');
				app.AnalyzedWhenEditField.Value = app.sici_info.analyzed_when;
			end
			if isprop(app, 'h_mep_analysis_comments')
				app.sici_info.comments = app.h_mep_analysis_comments.String;
			end
			% for emg_rc:
			if isprop(app, 'EMGDisplayRCUIFigure') && isgraphics(app.h_t_min_line)
				app.sici_info.mep_beg_t = app.h_t_min_line.XData(1);
			end
			if isprop(app, 'isgraphics(app.h_t_min_line)') && isgraphics(app.h_t_max_line)
				app.sici_info.mep_end_t = app.h_t_max_line.XData(1);
			end

			try
				write_fit_info(sici_info_fname, app.sici_info)
			catch ME
				disp('did not save sici_info')
				disp(ME)
			end
			% print the figure
			try
				print_rc([], [], app)
			catch ME
				disp('did not print the figure')
				disp(ME)
			end
		end
	end
	
	if strcmp(source.Tag, 'pushbutton')  % don't delete if the save pushbutton called this function
		return
	end
	
	% change checkbox
	if isprop(app, 'CheckBoxSici')
		app.CheckBoxSici.Value = 0;
	end
catch ME
	disp(ME)
	warning('SICI ICF Figure not saved')
% 	keyboard
end

% delete the figure
delete(source)
return