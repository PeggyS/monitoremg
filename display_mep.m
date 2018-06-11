function display_mep(app, param)

switch param
	case 'start'
		emg_fig  = findobj(0, 'Name', 'EMG Data');
		if isempty(emg_fig)
			app.emg_data_fig = figure('Position', [0   478   773   327], ...
				'NumberTitle', 'off', 'Name', 'EMG Data');

			init_disp_axes(app)
		end
		
		get_emg_data(app)
	case 'stop'
		close(app.emg_data_fig)
end 
