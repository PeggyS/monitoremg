function init_review_figs(app)
% create the main figure with table of data and emg data for each sample

% default mep begin & end times
mep_beg_t = 15;
mep_end_t = 90;
	
if isempty(app.emg_data_fig) || ~isgraphics(app.emg_data_fig)
	app.emg_data_fig = figure('Position', [466 86  1160  900], 'Name', 'EMG Data', ...
		'NumberTitle', 'off');
	app.h_disp_emg_axes = axes('Position', [0.6, 0.55,0.37,0.37], 'FontSize', 16);
	ylabel('EMG (\muV)')
	xlabel('Time (msec)')
	
	app.h_uitable = uitable('Position', [25,26,592,779], 'RowName', [], 'Tag', 'review_emg_uitable');
	
	% radiobuttons to choose how to compute MEP 
	app.h_radio_mep = uibuttongroup('Position', [0.1 0.92 0.125 0.065], ...
		'Title', 'MEP Calculation', ...
		'SelectionChangedFcn',{@mep_button_selection, app});
	r1 = uicontrol(app.h_radio_mep,'Style', 'radiobutton',...
                  'String','Amplitude',...
                  'Position',[2 25 90 25],...
                  'HandleVisibility','on', ...
				  'Tag', 'rb_mep_ampl'); %#ok<NASGU>
	r2 = uicontrol(app.h_radio_mep,'Style', 'radiobutton',...
                  'String','Area Under the Curve',...
                  'Position',[2 7 150 20],...
                  'HandleVisibility','on', ...
				  'Tag', 'rb_mep_auc'); %#ok<NASGU>

	app.h_stim_setup_text = uicontrol('Style', 'edit', 'Units', 'normalized', ...
		'Position', [0.23,0.92,0.14,0.04], 'Fontsize', 30, ...
		'FontWeight', 'bold', 'Enable', 'inactive', ...
		'String', 'Unknown', 'Visible', 'on', ...
		'Tag', 'stim_setup_text');
	uicontrol('Style', 'text', 'Units', 'normalized', ...
		'Position', [0.234,0.9584,0.1314,0.022], 'Fontsize', 15, ...
		'String', 'Hardware Setup:')
% 	app.preEmgMinEditField = uicontrol('Position', [0.3 0.92 0.2 0.1], ...
% 		'Style', 'edit', 'String', '-100');
	
	% buttons to Use all or use none
	uicontrol('Style', 'pushbutton', 'Units', 'normalized', ...
		'Position', [0.054,0.902,0.0448,0.016], 'Fontsize', 10, ...
		'String', 'Use All', ...
		'Callback', {@pushbutton_use, app, 'all'});
	uicontrol('Style', 'pushbutton', 'Units', 'normalized', ...
		'Position', [0.054,0.92,0.0448,0.016], 'Fontsize', 10, ...
		'String', 'Use None', ...
		'Callback', {@pushbutton_use, app, 'none'});

	uicontrol('Style', 'text', 'Units', 'normalized', ...
		'Position', [0.592,0.466,0.049,0.026], 'Fontsize', 16, ...
		'String', 'Epoch', ...
		'HorizontalAlignment', 'right')
	app.h_edit_epoch = uicontrol('Style', 'edit', ...
		'Units', 'normalized', 'Position', [0.643,0.466,0.0422,0.03], ...
		'Tag', 'edit_epoch', ...
		'String', num2str(0), 'fontsize', 16, ...
		'Callback', {@edit_epoch, app});

	% MEP begin, duration, and end times
	uicontrol('Style', 'text', 'Units', 'normalized', ...
		'Position', [0.59 0.43 0.08 0.03], 'Fontsize', 16, ...
		'String', 'MEP begin', ...
		'HorizontalAlignment', 'right')
	app.h_edit_mep_begin = uicontrol('Style', 'edit', ...
		'Units', 'normalized', 'Position', [0.6 0.4 0.06 0.03], ...
		'Tag', 'edit_mep_begin', ...
		'String', num2str(mep_beg_t), 'fontsize', 16, ...
		'Callback', {@edit_mep_limits, app});
	uicontrol('Style', 'text', 'Units', 'normalized', ...
		'Position', [0.7 0.43 0.08 0.03], 'Fontsize', 16, ...
		'String', 'MEP dur', ...
		'HorizontalAlignment', 'right')
	app.h_edit_mep_dur = uicontrol('Style', 'edit', ...
		'Units', 'normalized', 'Position', [0.72 0.4 0.06 0.03], ...
		'Tag', 'edit_mep_dur', ...
		'String', num2str(mep_end_t-mep_beg_t), 'fontsize', 16, ...
		'Callback', {@edit_mep_limits, app});
	uicontrol('Style', 'text', 'Units', 'normalized', ...
		'Position', [0.82 0.43 0.08 0.03], 'Fontsize', 16, ...
		'String', 'MEP end', ...
		'HorizontalAlignment', 'right')
	app.h_edit_mep_end = uicontrol('Style', 'edit', ...
		'Units', 'normalized', 'Position', [0.84, 0.4, 0.06, 0.03], ...
		'Tag', 'edit_mep_end', ...
		'String', num2str(mep_end_t), 'fontsize', 16, ...
		'Callback', {@edit_mep_limits, app});
	    
	app.h_autocompute_mep = uicontrol('Style', 'pushbutton', ...
		'Units', 'normalized', 'Position', [0.6 0.35 0.219 0.04], ...
		'Tag', 'autocompute_mep_pushbutton', ...
		'String', 'Compute MEP begin and end', 'fontsize', 16, 'Value', 0, ...
		'Callback', {@pushbutton_compute_mep_times, app});
   
	app.h_compute_close_mep_begin = uicontrol('Style', 'pushbutton', ...
		'Units', 'normalized', 'Position', [0.6,0.26,0.165,0.08], ...
		'FontSize', 12, ...
		'String', '<html>Move MEP begin line to the left<br />where mean line goes above the<br />preceeding derivative = 0</html>', ...
		'Callback', {@pushbutton_adj_mep_beg, app});
	app.h_compute_close_mep_end = uicontrol('Style', 'pushbutton', ...
		'Units', 'normalized', 'Position', [0.78,0.26,0.165,0.08], ...
		'FontSize', 12, ...
		'String', '<html>Move MEP end line to the right<br />where mean line derivative = 0</html>', ...
		'Callback', {@pushbutton_adj_mep_end, app});

	app.h_save_computed_mep_info = uicontrol('Style', 'pushbutton', ...
		'Units', 'normalized', 'Position', [0.6,0.216,0.18,0.04], ...
		'Tag', 'savecomputed_mep_pushbutton', ...
		'String', 'Save computed MEP info', 'fontsize', 16, 'Value', 0, ...
		'Callback', {@save_computed_mep_info, app});
   
	uicontrol('Style', 'text', 'Units', 'normalized', ...
		'Position', [0.6 0.16 0.056 0.0367], 'Fontsize', 12, ...
		'String', 'MEP times analysis by:', ...
		'HorizontalAlignment', 'left')
	app.h_edit_mep_done_by = uicontrol('Style', 'edit', ...
		'Units', 'normalized', 'Position', [0.6 0.1278 0.06 0.03], ...
		'Tag', 'edit_mep_done_by', ...
		'String', '', 'fontsize', 14);
	uicontrol('Style', 'text', 'Units', 'normalized', ...
		'Position', [0.6819 0.1678 0.0707 0.022], 'Fontsize', 12, ...
		'String', 'Analysis Date', ...
		'HorizontalAlignment', 'left')
	app.h_edit_mep_done_when = uicontrol('Style', 'edit', ...
		'Units', 'normalized', 'Position', [0.6724 0.1278 0.0905 0.03], ...
		'Tag', 'edit_mep_done_when', ...
		'String', '', 'fontsize', 14);
	app.h_using_data_txt = uicontrol('Style', 'text', 'Units', 'normalized', ...
		'Position', [0.769 0.1678 0.0707 0.022], 'Fontsize', 12, ...
		'String', 'Using xx data', ...
		'HorizontalAlignment', 'left');
	app.h_show_analysis_meps = uicontrol('Style', 'pushbutton', ...
		'Units', 'normalized', 'Position', [0.769,0.1244,0.1569,0.0367], ...
		'Tag', 'show_analysis_meps_pushbutton', ...
		'String', 'Show MEPs used for analysis', 'fontsize', 12, 'Value', 0, ...
		'Callback', {@show_analysis_meps, app});
	
	seg_time = (app.params.postTriggerTime + app.params.preTriggerTime) / 1000;
	seg_num_points = round(app.params.sampFreq*seg_time);
	t = (0:1/app.params.sampFreq:(seg_time-1/app.params.sampFreq))*1000 - app.params.preTriggerTime;

	% data line
	app.h_emg_line = line(app.h_disp_emg_axes, t, zeros(1, seg_num_points), ...
	  'LineWidth', 3) ;

	% lines at x,y = 0,0
	line(app.h_disp_emg_axes, app.h_disp_emg_axes.XLim, [0 0]);
	line(app.h_disp_emg_axes, [0 0], [-1e6 1e6]);

	% line at Test stim (when ISI > 0)
	app.h_cs_line = line(app.h_disp_emg_axes, [0 0], [-1e6 1e6], 'Color', 'red', 'Visible', 'off');

	% min & max vertical lines - draggable
	app.h_t_min_line = line(app.h_disp_emg_axes, [mep_beg_t mep_beg_t], [-1e6 1e6], ...
	  'LineWidth', 2, 'Color', [0 0.9 0], 'UserData', app, 'Tag', 'mep_min_line');
	draggable(app.h_t_min_line, 'h', [0 200], 'endfcn', @mep_line_drag_endfcn);
	app.h_t_max_line = line(app.h_disp_emg_axes, [mep_end_t mep_end_t], [-1e6 1e6], ...
	  'LineWidth', 2, 'Color', [0 0.9 0], 'UserData', app, 'Tag', 'mep_max_line');
	draggable(app.h_t_max_line, 'h', [0 200], 'endfcn', @mep_line_drag_endfcn);
	
	% pre-stim emg line
	app.h_pre_stim_emg_line = line(app.h_disp_emg_axes, ...
		app.h_disp_emg_axes.XLim, [1000 1000], 'Color', [0 0 0]);
	
	% emg auc line
	app.h_emg_auc_patch = patch(app.h_disp_emg_axes, ...
		[10 10 90 90], [10 100 100 10], [0.4 0.4 0.4]); 
	app.h_emg_auc_patch.FaceAlpha = 0.5;
	app.h_emg_auc_patch.Visible = 'off';

else
	% reset the data line
	seg_time = (app.params.postTriggerTime + app.params.preTriggerTime) / 1000;
	seg_num_points = round(app.params.sampFreq*seg_time);
	app.h_emg_line.YData = zeros(1, seg_num_points);

	% reset the mep min max lines
	app.h_t_min_line.XData = [mep_beg_t mep_beg_t];
	app.h_t_max_line.XData = [mep_end_t mep_end_t];
	
	% reset mep beg & end edit fields
	app.h_edit_mep_begin.String = num2str(mep_beg_t);
	app.h_edit_mep_end.String = num2str(mep_end_t);
	
	% reset prestim line & emg auc patch
	app.h_pre_stim_emg_line.YData = [1000 1000];
	app.h_emg_auc_patch.Vertices = [];
	app.h_emg_auc_patch.Faces = [];
end

title(app.h_disp_emg_axes, strrep(app.MuscleEditField.Value, '_', ' '))

% ======= rc or sici fig ===========
if app.CheckBoxRc.Value == 1
	% ISI conditioning stim line
	if isgraphics(app.h_label_isi)
		app.h_cs_line.Visible = 'off';
	end
	% create the recruitment curve figure
	init_rc_fig(app)
	if isgraphics(app.sici_fig)
		delete(app.sici_fig)
	end
elseif app.CheckBoxSici.Value == 1
	% ISI conditioning stim line
	app.h_cs_line.Visible = 'on';
	% create the sici, icf figure
	init_sici_fig(app)
	if isgraphics(app.rc_fig)
		delete(app.rc_fig)
	end
else
	if isgraphics(app.sici_fig)
		delete(app.sici_fig)
	end
	if isgraphics(app.rc_fig)
		delete(app.rc_fig)
	end
end

% % text display of MEP amplitude
% app.mep_value_text = uicontrol(app.emg_data_fig, 'Style', 'text', ...
% 			'String', num2str(1000), ...
% 			'Units', 'normalized', ...
% 			'Position', [0.7 0.85 0.29 0.14], ...
% 			'Fontsize', 50, 'ForegroundColor', 'b');
% 
% % text display of pre-emg value
% app.pre_emg_text = uicontrol(app.emg_data_fig, 'Style', 'text', ...
% 			'String', num2str(0), ...
% 			'Units', 'normalized', ...
% 			'Position', [0.08 0.06 0.13 0.075], ...
% 			'Fontsize',18, 'ForegroundColor', 'b');