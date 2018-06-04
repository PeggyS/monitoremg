function get_emg_data(app)
while app.CheckBoxDisplayMEP.Value
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

		set(app.mep_value_text, 'String', num2str(mep_val))
		if mep_val >= 200
			set(app.mep_value_text, 'ForegroundColor', 'r')
		else
			set(app.mep_value_text, 'ForegroundColor', 'b')
		end
		drawnow
		
		% if the rc figure window exists, plot the point
		rc_fig = findobj(0,'Name', 'Recruitment Curve');
		if ~isempty(rc_fig)
			
			% add the data to the axes userdata
			epoch = height(app.rc_axes.UserData) + 1;
			app.rc_axes.UserData.Epoch(epoch) = epoch;
			app.rc_axes.UserData.Use(epoch) = 1;
			app.rc_axes.UserData.MagStim_Setting(epoch) = magstim_val;
			app.rc_axes.UserData.MEPAmpl_uVPp(epoch) = mep_val;
			
			% add point to axes
			add_point2rc(app.rc_axes, epoch, magstim_val, mep_val)
		end
	end
	pause(0.5)
end % while true
