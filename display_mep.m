function display_mep(app, param)

switch param
	case 'start'
		app.emg_data_fig = figure('Position', [0   478   773   327], ...
			'NumberTitle', 'off', 'Name', 'EMG Data');

		init_disp_axes(app)
		app.mep_value_text = uicontrol(app.emg_data_fig, 'Style', 'text', ...
			'String', num2str(0), ...
			'Position', [620 270 155 60], ...
			'Fontsize', 50, 'ForegroundColor', 'b');
		
		get_emg_data(app)
	case 'stop'
		delete(app.emg_data_fig)
end 
