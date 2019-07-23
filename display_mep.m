function display_mep(app, param)

switch param
	case 'start'
		% get the muscle channels & update the app figure
		num_channels = app.data_channels_mmap.Data(1);
		if num_channels > 0
			for ch_cnt = 1:num_channels
				% get muscle names in data_channels_mmap
				app_chan = ['CheckBox_channel' num2str(ch_cnt)];
				app.(app_chan).Text = app.data_channels_mmap.Data(ch_cnt).muscle_name;
				app.(app_chan).Visible = 'on';
			end
		end
		for ch_cnt = num_channels+1:4
			app_chan = ['CheckBox_channel' num2str(ch_cnt)];
			app.(app_chan).Visible = 'off';
		end
		
		% init the emg display figure
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
