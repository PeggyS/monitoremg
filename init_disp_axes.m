function init_disp_axes(app)
% init the axes to display the emg data

app.h_disp_emg_axes = axes('FontSize', 16);
ylabel('EMG (µV)')
xlabel('Time (msec)')


seg_time = (app.params.postTriggerTime + app.params.preTriggerTime) / 1000;
seg_num_points = round(app.params.sampFreq*seg_time);
t = (0:1/app.params.sampFreq:(seg_time-1/app.params.sampFreq))*1000 - app.params.preTriggerTime;

% data line
app.h_emg_line = line(app.h_disp_emg_axes, t, zeros(1, seg_num_points), ...
  'LineWidth', 3) ;

% lines at x,y = 0,0
line(app.h_disp_emg_axes, app.h_disp_emg_axes.XLim, [0 0]);
line(app.h_disp_emg_axes, [0 0], [-1e6 1e6]);

% min & max vertical lines - draggable
app.h_t_min_line = line(app.h_disp_emg_axes, [15 15], [-1e6 1e6], ...
  'LineWidth', 2, 'Color', [0 0.9 0]);
draggable(app.h_t_min_line, 'h', [0 200])
app.h_t_max_line = line(app.h_disp_emg_axes, [90 90], [-1e6 1e6], ...
  'LineWidth', 2, 'Color', [0 0.9 0]);
draggable(app.h_t_max_line, 'h', [0 200])

% text display of MEP amplitude
app.mep_value_text = uicontrol(app.emg_data_fig, 'Style', 'text', ...
			'String', num2str(1000), ...
			'Units', 'normalized', ...
			'Position', [0.7 0.85 0.29 0.14], ...
			'Fontsize', 50, 'ForegroundColor', 'b');

% text display of pre-emg value
app.pre_emg_text = uicontrol(app.emg_data_fig, 'Style', 'text', ...
			'String', num2str(0), ...
			'Units', 'normalized', ...
			'Position', [0.08 0.06 0.13 0.075], ...
			'Fontsize',18, 'ForegroundColor', 'b');

% set a close function to uncheck the display MEP checkbox
app.emg_data_fig.CloseRequestFcn = {@close_mep_fig, app};
