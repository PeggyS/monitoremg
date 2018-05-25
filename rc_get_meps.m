function rc_get_meps(app)

while app.StartButton.Value
	% if the display emg app is sending new data
	new_data = app.rc_data_mmap.Data(1).new_data;
	if new_data
		magstim_val = app.rc_data_mmap.Data(1).magstim_val;
		mep_val = app.rc_data_mmap.Data(1).mep_val;

		app.rc_data = [app.rc_data; 1, magstim_val, mep_val];

		add_point2rc(app.UIAxes, magstim_val, mep_val)

		% done with the new data, reset for the next time
		app.rc_data_mmap.Data(1).new_data = uint8(0);
	end

	pause(0.5)
end