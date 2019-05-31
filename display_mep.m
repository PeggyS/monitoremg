function display_mep(app, param)

switch param
	case 'start'
		emg_fig  = findobj(0, 'Name', 'EMG Data');
		if isempty(emg_fig)
			app.emg_data_fig = figure('Position', [1544 20 506 440], ...
				'NumberTitle', 'off', 'Name', 'EMG Data', ...
				'MenuBar', 'none', 'ToolBar', 'none');

			init_disp_axes(app)
		end
		
		get_emg_data(app)
	case 'stop'
		close(app.emg_data_fig)
end 
