function display_mep(app, param)

switch param
	case 'start'
		app.emg_data_fig = figure('Position', [0   478   773   327], ...
			'NumberTitle', 'off', 'Name', 'EMG Data');

		init_disp_axes(app)
		
		get_emg_data(app)
	case 'stop'
		delete(app.emg_data_fig)
end 
