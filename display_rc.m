function display_rc(app, param)

switch param
	case 'start'
		init_rc_fig(app)
		% If there is not a figure with the name 'emg data', then
		% we are not getting live data from magstim & brainvision.
		% We are probably debugging or want to enter data from a file.
		h_emg = findobj(0, 'Name', 'EMG Data');
		if isempty(h_emg)
			% Add button to load data
			h = uicontrol(app.rc_fig, 'Style', 'pushbutton', ...
				'String', 'Load Data', ...
				'Units', 'normalized', ...
				'Position', [0.05 0.03 0.2 0.05], ...
				'Fontsize', 20, ...
				'Callback', {@load_stim_emg_data, app.rc_axes});
		end
		% clear any existing fit_info
		app.rc_fit_info = [];
		
	case 'stop'
		close(app.rc_fig)
end 
