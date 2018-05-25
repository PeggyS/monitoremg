function get_emg_data(app)
while app.StartButton.Value
	% if the emg monitor app is sending new data
	new_data = app.emg_data_mmap.Data(1).new_data;
	if new_data
		magstim_val = app.emg_data_mmap.Data(1).magstim_val;
		% 		disp(['magstim_val = ', num2str(magstim_val)]);
		emg_data = app.emg_data_mmap.Data(1).emg_data;
		
		% display the data
		app.h_emg_line.YData = emg_data;
		
		% adjust y limits
		app.UIAxes.YLim = [min(emg_data) max(emg_data)];
		
		% set new_data to false
		app.emg_data_mmap.Data(1).new_data = uint8(0);
		
		
		% get mep value & put it in the recruit curve memmapfile
		t_emg = app.h_emg_line.XData;
		t_mep_min = app.h_t_min_line.XData(1);
		t_mep_max = app.h_t_max_line.XData(1);
		mep_seg = emg_data(t_emg>t_mep_min & t_emg<t_mep_max);
		
		mep_val = max(mep_seg) - min(mep_seg);
		app.rc_data_mmap.Data(1).new_data = uint8(1);
		app.rc_data_mmap.Data(1).magstim_val = uint8(magstim_val);
		app.rc_data_mmap.Data(1).mep_val = mep_val;

	end
	pause(0.5)
end % while true
