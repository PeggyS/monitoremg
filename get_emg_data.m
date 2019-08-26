function get_emg_data(app)
warning('off', 'MATLAB:table:RowsAddedExistingVars');

while app.CheckBoxDisplayMEP.Value
	if ~isempty(app.emg_data_mmap)
		save_chan_list = [];
		% if saving data
		if app.CheckBoxSavedata.Value
			% find the live_display channel
			% if the live_display channel has changed, update the default
			% channel save checkboxes
			ch_struc = app.data_channels_mmap.Data;
			for c_cnt = 1:ch_struc(1).num_channels
				chkbox_var = ['CheckBox_channel' num2str(c_cnt)];
				if ch_struc(c_cnt).live_display 
					app.(chkbox_var).Value = 1;
					live_chan_num = c_cnt;
				else
					app.(chkbox_var).Value = 0;
				end
				if ch_struc(c_cnt).save
					save_chan_list = [save_chan_list, c_cnt]; %#ok<AGROW>
				end
			end
		end
		
		% if the emg monitor app is sending new data
		new_data = app.emg_data_mmap.Data(1).new_data;
		if new_data
			magstim_val = app.emg_data_mmap.Data(1).magstim_val;
			% 		disp(['magstim_val = ', num2str(magstim_val)]);
			emg_data = app.emg_data_mmap.Data(1).emg_data;


			muscle = strip(char(app.emg_data_mmap.Data(1).muscle_name));
			% save the data 
			if app.CheckBoxSavedata.Value 
				if isempty(app.SaveLocationEditField.Value)
					app.SaveLocationEditField.Value = pwd;
				end

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
						warning('Data being appended to %s', app.fullfilename)
					end
				end
				fprintf(fid, '%d', app.active_sample_checkbox.Value);
				fprintf(fid, ',%d', magstim_val);
	         	fprintf(fid, ',%f', emg_data);
	         	fclose(fid);
				app.SaveFileName.Text = [shortfilename '.txt'];
	         	app.fname_sample_struct.(shortfilename) = app.fname_sample_struct.(shortfilename) + 1;
	         	app.sample_num_text.String = num2str(app.fname_sample_struct.(shortfilename));
			else
				app.SaveFileName.Text = 'no file';
			end
			
			% title = channel/muscle
			muscle = strrep(muscle, '_', ' ');
			title(app.h_disp_emg_axes, muscle, 'FontSize', 20)
			% set new_data to false
			app.emg_data_mmap.Data(1).new_data = uint8(0);

			% monitor emg's value
			monitor_emg_val = app.emg_data_mmap.Data(1).monitor_emg_val;

% 			% display the data
			[mep_val, pre_stim_val] = draw_emg_data(app, emg_data, monitor_emg_val, ...
				app.emg_data_mmap.Data(1).goal_min, app.emg_data_mmap.Data(1).goal_max);

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
				app.rc_axes.UserData.MagStim_Setting(epoch) = magstim_val;
				app.rc_axes.UserData.MEPAmpl_uVPp(epoch) = mep_val;
				app.rc_axes.UserData.PreStimEmg_100ms(epoch) = pre_stim_val;
				app.rc_axes.UserData.MonitorEMGval(epoch) = monitor_emg_val;
				app.rc_axes.UserData.GoalEMG(epoch) = app.emg_data_mmap.Data(1).goal_val;
				app.rc_axes.UserData.GoalEMGmin(epoch) = app.emg_data_mmap.Data(1).goal_min;
				app.rc_axes.UserData.GoalEMGmax(epoch) = app.emg_data_mmap.Data(1).goal_max;
				% norm factor
				norm_factor = str2double(app.rc_fit_ui.edNormFactor.String);
				% add point to axes
				add_point2rc(app.rc_axes, epoch, magstim_val, mep_val/norm_factor)
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
				app.sici_axes.UserData.MagStim_Setting(epoch) = magstim_val;
				app.sici_axes.UserData.Sici_or_icf_or_ts(epoch) = {'?'};
				app.sici_axes.UserData.MEPAmpl_uVPp(epoch) = mep_val;
				app.sici_axes.UserData.PreStimEmg_100ms(epoch) = pre_stim_val;
				app.sici_axes.UserData.MonitorEMGval(epoch) = monitor_emg_val;
				app.sici_axes.UserData.GoalEMG(epoch) = app.emg_data_mmap.Data(1).goal_val;
				app.sici_axes.UserData.GoalEMGmin(epoch) = app.emg_data_mmap.Data(1).goal_min;
				app.sici_axes.UserData.GoalEMGmax(epoch) = app.emg_data_mmap.Data(1).goal_max;
				% norm factor
				norm_factor = 1;  %str2double(app.rc_fit_ui.edNormFactor.String);
				% add point to axes
				add_point2sici(app, epoch, magstim_val, mep_val/norm_factor)	
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
