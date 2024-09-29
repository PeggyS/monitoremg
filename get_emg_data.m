function get_emg_data(app)
warning('off', 'MATLAB:table:RowsAddedExistingVars');
prev_live_chan = -1;

while app.CheckBoxDisplayMEP.Value
	if ~isempty(app.emg_data_mmap)
		
		ch_struc = app.data_channels_mmap.Data;
		% find the live display channel & if it has changed
		for c_cnt = 1:ch_struc(1).num_channels
			if ch_struc(c_cnt).live_display 
				live_chan_num = c_cnt;
			end
		end

		% if saving data
		if app.CheckBoxSavedata.Value
			% find the live_display channel
			% if the live_display channel has changed, update the default
			% channel save checkboxes
			for c_cnt = 1:ch_struc(1).num_channels
				chkbox_var = ['CheckBox_channel' num2str(c_cnt)];
				if logical(ch_struc(c_cnt).live_display) && (c_cnt ~= prev_live_chan)
					app.(chkbox_var).Value = 1;
% 					live_chan_num = c_cnt;
					if prev_live_chan > 0
						chkbox_var = ['CheckBox_channel' num2str(prev_live_chan)];
						app.(chkbox_var).Value = 0;
					end
					prev_live_chan = live_chan_num;
				end
				app.data_channels_mmap.Data(c_cnt).save = uint8(app.(chkbox_var).Value);

			end
		end
		
		% if the emg monitor app is sending new data
		new_data = app.emg_data_mmap.Data(1).new_data;
		if new_data
			stim_info.magstim_val = double(app.emg_data_mmap.Data(live_chan_num).magstim_val);
			stim_info.bistim_val = double(app.emg_data_mmap.Data(live_chan_num).bistim_val);
			stim_info.isi_ms = double(app.emg_data_mmap.Data(live_chan_num).isi_ms);
			stim_info.effective_so = nan;
			% single magstim (upper/master stimulator)
			if stim_info.magstim_val > 0 && stim_info.bistim_val == 0 && stim_info.isi_ms > 0
% 				disp('master stimulator')
				stim_info.effective_so = round(0.9 * stim_info.magstim_val);
			% single slave stimulator
			elseif stim_info.magstim_val == 0 && stim_info.bistim_val > 0
% 				disp('slave stimulator')
				stim_info.effective_so = round(0.9 * stim_info.bistim_val);
			% simultaneous discharge of bistim
			elseif stim_info.magstim_val == stim_info.bistim_val && ...
					stim_info.isi_ms == 0
% 				disp('simultaneous discharge')
				stim_info.effective_so = round(1.13 * stim_info.magstim_val);
			% single magstim hardware setup
			elseif stim_info.bistim_val == 0 && stim_info.isi_ms == 0
% 				disp('magstim only')
				stim_info.effective_so = stim_info.magstim_val;
			end
			% 		disp(['magstim_val = ', num2str(magstim_val)]);
			
			% save the data 
			if app.CheckBoxSavedata.Value 
				if isempty(app.SaveLocationEditField.Value)
					app.SaveLocationEditField.Value = pwd;
				end

				for c_cnt = 1:ch_struc(1).num_channels
					if ch_struc(c_cnt).save
						muscle = strip(char(ch_struc(c_cnt).muscle_name));
						emg_data = app.emg_data_mmap.Data(c_cnt).emg_data;
						% add rc or sici if their figure is being displayed
						rc_or_sici = '';
						if app.CheckBoxRecruitCurve.Value
							rc_or_sici = '_rc';
						elseif app.CheckBoxSici.Value
							rc_or_sici = '_sici';
						elseif app.CheckBoxAverageEmg.Value
							rc_or_sici = '_avg';
						end

						shortfilename = [app.EditFieldFilenameprefix.Value muscle ...
							rc_or_sici '_emg_data'];
						pathfilename = [app.SaveLocationEditField.Value '/' ...
							shortfilename];
						app.fullfilename = [pathfilename '.txt'];

						% number the samples saved in the file
						if ~isfield(app.fname_sample_struct, shortfilename)
							app.fname_sample_struct.(shortfilename) = 0;
						end
						fid = fopen(app.fullfilename, 'a');
						if ftell(fid) > 0 % already data in the file
							fprintf(fid, '\n'); % start a new line of data
							if app.fname_sample_struct.(shortfilename) == 0
								% data being appended to an existing file, but the app is 
								% counting samples from 0 - warn the user
								beep
								warning('Data being appended to %s\nWindow numbers and file line numbers will not agree!', app.fullfilename)
							end
						end
						fprintf(fid, '%d', app.active_sample_checkbox.Value);
						fprintf(fid, ',%d', stim_info.magstim_val);
						fprintf(fid, ',%d', stim_info.bistim_val);
						fprintf(fid, ',%d', stim_info.isi_ms);
						fprintf(fid, ',%d', stim_info.effective_so);
						fprintf(fid, ',%f', emg_data);
						fclose(fid);
						app.SaveFileName.Text = [shortfilename '.txt'];
						app.fname_sample_struct.(shortfilename) = app.fname_sample_struct.(shortfilename) + 1;
						app.sample_num_text.String = num2str(app.fname_sample_struct.(shortfilename));
					end
				end % for loop thru each channel to see if saving it
			else
				app.SaveFileName.Text = 'no file';
			end
			
			% data to display
			emg_data = app.emg_data_mmap.Data(live_chan_num).emg_data;
			muscle = strip(char(app.emg_data_mmap.Data(live_chan_num).muscle_name));
			% title = channel/muscle
			muscle = strrep(muscle, '_', ' ');
			title(app.h_disp_emg_axes, muscle, 'FontSize', 20)
			% set new_data to false
			app.emg_data_mmap.Data(1).new_data = uint8(0);

			% monitor emg's value
			monitor_emg_val = app.emg_data_mmap.Data(live_chan_num).monitor_emg_val;

			% filter the data to display
			filt_data = filtfilt(app.display_filter, emg_data);
% 			% display the data
			[mep_val, pre_stim_val] = draw_emg_data(app, filt_data, monitor_emg_val, ...
				app.emg_data_mmap.Data(live_chan_num).goal_min, ...
				app.emg_data_mmap.Data(live_chan_num).goal_max, stim_info);
			

			% if the rc figure window exists, plot the point
			rc_fig = findobj(0,'Name', 'Recruitment Curve');
			if ~isempty(rc_fig)
				% add title 
				if isempty(app.rc_axes.Title.String)
					app.rc_axes.Title.String = muscle;
				end
				
				% add the data to the axes userdata
				epoch = height(app.rc_axes.UserData) + 1;
				% next line generates warning:
					% Warning: The assignment added rows to the table, but did not assign values to all of the
					% table's existing variables. Those variables have been extended with rows containing default
					% values.
				app.rc_axes.UserData.Epoch(epoch) = epoch;
				app.rc_axes.UserData.Use(epoch) = 1; % in_goal_range
				app.rc_axes.UserData.MagStim_Setting(epoch) = stim_info.magstim_val;
				app.rc_axes.UserData.BiStim_Setting(epoch) = stim_info.bistim_val;
				app.rc_axes.UserData.ISI_ms(epoch) = stim_info.isi_ms;
				app.rc_axes.UserData.Effective_SO(epoch) = stim_info.effective_so;
				app.rc_axes.UserData.MEPAmpl_uVPp(epoch) = mep_val;
				app.rc_axes.UserData.PreStimEmg_100ms(epoch) = pre_stim_val;
				app.rc_axes.UserData.MonitorEMGval(epoch) = monitor_emg_val;
				app.rc_axes.UserData.GoalEMG(epoch) = app.emg_data_mmap.Data(live_chan_num).goal_val;
				app.rc_axes.UserData.GoalEMGmin(epoch) = app.emg_data_mmap.Data(live_chan_num).goal_min;
				app.rc_axes.UserData.GoalEMGmax(epoch) = app.emg_data_mmap.Data(live_chan_num).goal_max;
				% norm factor
				norm_factor = str2double(app.rc_fit_ui.edNormFactor.String);
				% add point to axes
				add_point2rc(app.rc_axes, epoch, stim_info.magstim_val, mep_val/norm_factor)
			end

			% if sici figure exists, plot the point
			sici_fig = findobj(0, 'Name', 'SICI & ICF');
			if ~isempty(sici_fig)
				if isempty(app.sici_axes.Title.String)
					app.sici_axes.Title.String = muscle;
				end
				% add the data to the axes userdata
				epoch = height(app.sici_axes.UserData) + 1;
				% next line generates warning:
					% Warning: The assignment added rows to the table, but did not assign values to all of the
					% table's existing variables. Those variables have been extended with rows containing default
					% values.
				app.sici_axes.UserData.Epoch(epoch) = epoch;
				app.sici_axes.UserData.Use(epoch) = 1; % in_goal_range
				app.sici_axes.UserData.MagStim_Setting(epoch) = stim_info.magstim_val;
				app.sici_axes.UserData.BiStim_Setting(epoch) = stim_info.bistim_val;
				app.sici_axes.UserData.ISI_ms(epoch) = stim_info.isi_ms;
				app.sici_axes.UserData.Stim_Type(epoch) = {'?'};
				app.sici_axes.UserData.MEPAmpl_uVPp(epoch) = mep_val;
				app.sici_axes.UserData.PreStimEmg_100ms(epoch) = pre_stim_val;
				app.sici_axes.UserData.MonitorEMGval(epoch) = monitor_emg_val;
				app.sici_axes.UserData.GoalEMG(epoch) = app.emg_data_mmap.Data(live_chan_num).goal_val;
				app.sici_axes.UserData.GoalEMGmin(epoch) = app.emg_data_mmap.Data(live_chan_num).goal_min;
				app.sici_axes.UserData.GoalEMGmax(epoch) = app.emg_data_mmap.Data(live_chan_num).goal_max;
				% norm factor
				norm_factor = 1;  %str2double(app.rc_fit_ui.edNormFactor.String);
				% add point to axes
				add_point2sici(app, epoch, mep_val/norm_factor)	
			end
			% if the average figure exists, update it
			avg_fig = findobj(0, 'Name', 'Average EMG');
			if ~isempty(avg_fig)
				update_avg_emg([], [], app)
			end
		end
	end
	pause(0.5)
end % while true

warning('on', 'MATLAB:table:RowsAddedExistingVars');
