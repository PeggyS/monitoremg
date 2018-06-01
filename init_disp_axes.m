function init_disp_axes(app)

app.h_disp_emg_axes = axes;
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
app.h_t_min_line = line(app.h_disp_emg_axes, [10 10], [-1e6 1e6], ...
  'LineWidth', 2, 'Color', [0 0.9 0]);
draggable(app.h_t_min_line, 'h', [0 200])
app.h_t_max_line = line(app.h_disp_emg_axes, [70 70], [-1e6 1e6], ...
  'LineWidth', 2, 'Color', [0 0.9 0]);
draggable(app.h_t_max_line, 'h', [0 200])

% text display of MEP amplitude
app.mep_value_text = uicontrol(app.emg_data_fig, 'Style', 'text', ...
			'String', num2str(0), ...
			'Units', 'normalized', ...
			'Position', [0.8008 0.8226 0.2005 0.1835], ...
			'Fontsize', 50, 'ForegroundColor', 'b');