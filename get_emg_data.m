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
	end
 	pause(0.5)
end

return