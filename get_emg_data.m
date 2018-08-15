function get_emg_data(app)
warning('off', 'MATLAB:table:RowsAddedExistingVars');

while app.CheckBoxDisplayMEP.Value
	if ~isempty(app.emg_data_mmap)
		% if the emg monitor app is sending new data
		new_data = app.emg_data_mmap.Data(1).new_data;
		if new_data
			magstim_val = app.emg_data_mmap.Data(1).magstim_val;
			% 		disp(['magstim_val = ', num2str(magstim_val)]);
			emg_data = app.emg_data_mmap.Data(1).emg_data;

			% display the data
			app.h_emg_line.YData = emg_data;

			% adjust y limits
			app.h_disp_emg_axes.YLim = [min(emg_data) max(emg_data)];

			muscle = strip(char(app.emg_data_mmap.Data(1).muscle_name));
			% save the data 
			if app.CheckBoxSavedata.Value 
				filename = [app.SaveLocationEditField.Value '/' app.EditFieldFilenameprefix.Value muscle ...
					'_emg_data.txt'];
				fid = fopen(filename, 'a');
				if ftell(fid) > 0 % already data in the file
					fprintf(fid, '\n'); % start a new line of data
				end
				fprintf(fid, '%d', magstim_val);
	         	fprintf(fid, ',%f', emg_data);
	         	fclose(fid);
			end
			
			% title = channel/muscle
			muscle = strrep(muscle, '_', ' ');
			title(app.h_disp_emg_axes, muscle, 'FontSize', 20)
			% set new_data to false
			app.emg_data_mmap.Data(1).new_data = uint8(0);


			% get mep value & put it in the recruit curve memmapfile
			t_emg = app.h_emg_line.XData;
			t_mep_min = app.h_t_min_line.XData(1);
			t_mep_max = app.h_t_max_line.XData(1);
			mep_seg = emg_data(t_emg>t_mep_min & t_emg<t_mep_max);

			mep_val = max(mep_seg) - min(mep_seg);
	% 		app.rc_data_mmap.Data(1).new_data = uint8(1);
	% 		app.rc_data_mmap.Data(1).magstim_val = uint8(magstim_val);
	% 		app.rc_data_mmap.Data(1).mep_val = mep_val;

			set(app.mep_value_text, 'String', num2str(round(mep_val)))
			if mep_val >= 200
				set(app.mep_value_text, 'ForegroundColor', 'r')
			else
				set(app.mep_value_text, 'ForegroundColor', 'b')
			end

			% compute the pre-stim emg
			pre_stim_data = app.h_emg_line.YData(app.h_emg_line.XData>=-51 ...
				& app.h_emg_line.XData<-1); % 50 ms prior to stim (+ 1 ms to allow for stim artifact)
			pre_stim_val = mean(abs(pre_stim_data) - mean(pre_stim_data));
			set(app.pre_emg_text, 'String', num2str(round(pre_stim_val)))
			% change the color depending on the proximity to the goal

			drawnow

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
				app.rc_axes.UserData.Use(epoch) = 1;
				app.rc_axes.UserData.MagStim_Setting(epoch) = magstim_val;
				app.rc_axes.UserData.MEPAmpl_uVPp(epoch) = mep_val;
				% norm factor
				norm_factor = str2double(app.rc_fit_ui.edNormFactor.String);
				% add point to axes
				add_point2rc(app.rc_axes, epoch, magstim_val, mep_val/norm_factor)
			end
		end
	end
	pause(0.5)
end % while true

warning('on', 'MATLAB:table:RowsAddedExistingVars');
