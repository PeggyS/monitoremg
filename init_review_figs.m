function init_review_figs(app)
% create the main figure with table of data and emg data for each sample

% default mep begin & end times
mep_beg_t = 15;
mep_end_t = 90;

% define different fontsizes for mac & pc
if ismac
    axes_fontsize = 16;
    stim_setup_text_fontsize = 30;
    mep_info_fontsize = 16;
    large_button_fontsize = 12;
    analysis_edit_fontsize = 12;
    analysis_label_fontsize = 14;
else
    axes_fontsize = 12;
    stim_setup_text_fontsize = 20;
    mep_info_fontsize = 12;
    large_button_fontsize = 10;
    analysis_edit_fontsize = 10;
    analysis_label_fontsize = 12;
end
	
if isempty(app.emg_data_fig) || ~isgraphics(app.emg_data_fig)
	app.emg_data_fig = figure('Position', [0,0,1650,960], 'Name', 'EMG Data', ...
		'NumberTitle', 'off', 'CreateFcn',@movegui);
	app.h_disp_emg_axes = axes('Position', [0.6, 0.55,0.37,0.37], 'FontSize', axes_fontsize);
	ylabel('EMG (\muV)')
	xlabel('Time (msec)')
	
	app.h_uitable = uitable('Position', [5,24,876,865], 'RowName', [], 'Tag', 'review_emg_uitable');
	
	% radiobuttons to choose how to compute MEP 
	app.h_radio_mep = uibuttongroup('Position', [0.1 0.92 0.125 0.065], ...
		'Title', 'MEP Calculation', ...
		'SelectionChangedFcn',{@mep_button_selection, app}, 'Visible','off');
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
		'Position', [0.23,0.935,0.14,0.04], 'Fontsize', stim_setup_text_fontsize, ...
		'FontWeight', 'bold', 'Enable', 'inactive', ...
		'String', 'Unknown', 'Visible', 'on', ...
		'Tag', 'stim_setup_text');
	uicontrol('Style', 'text', 'Units', 'normalized', ...
		'Position', [0.234,0.975,0.1314,0.022], 'Fontsize', 15, ...
		'String', 'Hardware Setup:')
% 	app.preEmgMinEditField = uicontrol('Position', [0.3 0.92 0.2 0.1], ...
% 		'Style', 'edit', 'String', '-100');
	
	% buttons to Use all or use none
	uicontrol('Style', 'pushbutton', 'Units', 'normalized', ...
		'Position', [0.0236,0.9296,0.0448,0.016], 'Fontsize', 10, ...
		'String', 'Use All', ...
		'Callback', {@pushbutton_use, app, 'all'});
	uicontrol('Style', 'pushbutton', 'Units', 'normalized', ...
		'Position', [0.0236,0.9500,0.0448,0.016], 'Fontsize', 10, ...
		'String', 'Use None', ...
		'Callback', {@pushbutton_use, app, 'none'});

	uicontrol('Style', 'text', 'Units', 'normalized', ...
		'Position', [0.538868117797694,0.460447471324296,0.040030729833547,0.026], 'Fontsize', mep_info_fontsize, ...
		'String', 'Epoch', ...
		'HorizontalAlignment', 'right')
	app.h_edit_epoch = uicontrol('Style', 'edit', ...
		'Units', 'normalized', 'Position', [0.582590695689286,0.461530804657629,0.0422,0.03], ...
		'Tag', 'edit_epoch', ...
		'String', num2str(0), 'fontsize', 16, ...
		'Callback', {@edit_epoch, app});

	% MEP begin, duration, and end times
	uicontrol('Style', 'text', 'Units', 'normalized', ...
		'Position', [0.59 0.43 0.08 0.03], 'Fontsize', mep_info_fontsize, ...
		'String', 'MEP begin', ...
		'HorizontalAlignment', 'right')
	app.h_edit_mep_begin = uicontrol('Style', 'edit', ...
		'Units', 'normalized', 'Position', [0.6 0.4 0.06 0.03], ...
		'Tag', 'edit_mep_begin', ...
		'String', num2str(mep_beg_t), 'fontsize', mep_info_fontsize, ...
		'Callback', {@edit_mep_limits, app});
	uicontrol('Style', 'text', 'Units', 'normalized', ...
		'Position', [0.684 0.43 0.0645 0.03], 'Fontsize', mep_info_fontsize, ...
		'String', 'MEP dur', ...
		'HorizontalAlignment', 'right')
	app.h_edit_mep_dur = uicontrol('Style', 'edit', ...
		'Units', 'normalized', 'Position', [0.689 0.4 0.06 0.03], ...
		'Tag', 'edit_mep_dur', ...
		'String', num2str(mep_end_t-mep_beg_t), 'fontsize', mep_info_fontsize, ...
		'Callback', {@edit_mep_limits, app});
	uicontrol('Style', 'text', 'Units', 'normalized', ...
		'Position', [0.777 0.43 0.0612 0.03], 'Fontsize', mep_info_fontsize, ...
		'String', 'MEP end', ...
		'HorizontalAlignment', 'right')
	app.h_edit_mep_end = uicontrol('Style', 'edit', ...
		'Units', 'normalized', 'Position', [0.778, 0.4, 0.06, 0.03], ...
		'Tag', 'edit_mep_end', ...
		'String', num2str(mep_end_t), 'fontsize', mep_info_fontsize, ...
		'Callback', {@edit_mep_limits, app});

	uicontrol('Style', 'text', 'Units', 'normalized', ...
		'Position', [0.851 0.43 0.0612 0.0443], 'Fontsize', analysis_label_fontsize, ...
		'String', 'MEP-max SO', ...
		'HorizontalAlignment', 'center', 'Visible','off')
	app.h_edit_mep_max_so = uicontrol('Style', 'edit', ...
		'Units', 'normalized', 'Position', [0.855, 0.4, 0.06, 0.03], ...
		'Tag', 'edit_mep_max_so', ...
		'String', 'xxx', 'fontsize', mep_info_fontsize, 'Visible','off');    
	
	uicontrol('Style', 'text', 'Units', 'normalized', ...
		'Position', [0.93 0.43 0.063 0.0464], 'Fontsize', analysis_label_fontsize, ...
		'String', 'Num Std Deviations', ...
		'HorizontalAlignment', 'center')
	app.h_num_std = uicontrol('Style', 'edit', ...
		'Units', 'normalized', 'Position', [0.93 0.4 0.06 0.03], ...
		'Tag', 'edit_num_std', ...
		'String', '3', 'fontsize', mep_info_fontsize);
	
	app.h_autocompute_mep = uicontrol('Style', 'pushbutton', ...
		'Units', 'normalized', 'Position', [0.6 0.35 0.25 0.04], ...
		'Tag', 'autocompute_mep_pushbutton', ...
		'String', 'Compute MEP begin, end and Save', 'fontsize', mep_info_fontsize, ...
		'Callback', {@pushbutton_compute_mep_times, app}, ...
		'Visible', 'off');
	app.h_rc_plateau_checkbox = uicontrol('Style', 'checkbox', ...
		'Units', 'normalized', 'Position', [0.86,0.353,0.1289,0.04], ...
		'Tag', 'autocompute_mep_pushbutton', ...
		'String', '<html>Recruitment curve<br />plateaued?</html>', ...
		'FontSize', analysis_label_fontsize, ...
		'ForegroundColor', [0.9 0.1 0]);
   
	app.h_select_meps = uicontrol('Style', 'pushbutton', ...
		'Units', 'normalized', 'Position', [0.6 0.354 0.25 0.04], ...
		'Tag', 'select_meps_pushbutton', ...
		'String', 'Select MEPs at the selected row stim level', 'fontsize', analysis_label_fontsize, ...
		'Callback', {@pushbutton_select_meps, app});
	
	app.h_compute_close_mep_begin_old = uicontrol('Style', 'pushbutton', ...
		'Units', 'normalized', 'Position', [0.6,0.30,0.202,0.0556], ...
		'FontSize', large_button_fontsize, ...
		'String', '<html>Move MEP BEGIN line to the <font color="purple">left</font><br /> from MEP using derivative</html>', ...
		'Callback', {@pushbutton_adj_mep_beg_old_method, app});
	app.h_compute_close_mep_end_old = uicontrol('Style', 'pushbutton', ...
		'Units', 'normalized', 'Position', [0.8076,0.30,0.165,0.0556], ...
		'FontSize', large_button_fontsize, ...
		'String', '<html>Move MEP END line to the <font color="green">right</font><br />from MEP using derivative</html>', ...
		'Callback', {@pushbutton_adj_mep_end_old_method, app});

	app.h_compute_close_mep_begin = uicontrol('Style', 'pushbutton', ...
		'Units', 'normalized', 'Position', [0.6,0.247,0.202,0.0556], ...
		'FontSize', large_button_fontsize, ...
		'String', '<html>Move MEP BEGIN line to the <font color="green">right</font> where<br />mean line exceeds the prestim std dev</html>', ...
		'Callback', {@pushbutton_adj_mep_beg, app});
	app.h_compute_close_mep_end = uicontrol('Style', 'pushbutton', ...
		'Units', 'normalized', 'Position', [0.8076,0.247,0.165,0.0556], ...
		'FontSize', large_button_fontsize, ...
		'String', '<html>Move MEP END line to the <font color="purple">left</font><br />where mean line exceeds std dev</html>', ...
		'Callback', {@pushbutton_adj_mep_end, app});

	app.h_save_computed_mep_info = uicontrol('Style', 'pushbutton', ...
		'Units', 'normalized', 'Position', [0.6,0.206,0.202,0.04], ...
		'Tag', 'savecomputed_mep_pushbutton', ...
		'String', 'Save datapoint table', 'fontsize', mep_info_fontsize, 'Value', 0, ...
		'Callback', {@save_computed_mep_info, app});
	app.h_compute_non_mep_ampl = uicontrol('Style', 'pushbutton', ...
		'Units', 'normalized', 'Position', [0.8076,0.206,0.165,0.04], ...
		'Tag', 'compute_non_mep_ampl_pushbutton', ...
		'String', 'Compute non-MEP Ampl', 'fontsize', mep_info_fontsize, 'Value', 0, ...
		'Callback', {@compute_non_mep_ampl, app});

	uicontrol('Style', 'pushbutton', ...
		'Units', 'normalized', 'Position', [0.55,0.126,0.05,0.0333], ...
		'Tag', 'update_initials_and_date', ...
		'String', 'Update:', 'fontsize', analysis_edit_fontsize,  ...
		'Callback', {@update_initials_and_date, app});
	uicontrol('Style', 'text', 'Units', 'normalized', ...
		'Position', [0.6 0.16 0.056 0.0367], 'Fontsize', large_button_fontsize, ...
		'String', 'MEP times analysis by:', ...
		'HorizontalAlignment', 'left')
	app.h_edit_mep_done_by = uicontrol('Style', 'edit', ...
		'Units', 'normalized', 'Position', [0.6 0.1278 0.06 0.03], ...
		'Tag', 'edit_mep_done_by', ...
		'String', '', 'fontsize', analysis_edit_fontsize);
	uicontrol('Style', 'text', 'Units', 'normalized', ...
		'Position', [0.6819 0.1678 0.0845 0.022], 'Fontsize', analysis_label_fontsize, ...
		'String', 'Analysis Date', ...
		'HorizontalAlignment', 'left')
	app.h_edit_mep_done_when = uicontrol('Style', 'edit', ...
		'Units', 'normalized', 'Position', [0.6672 0.1278 0.1086 0.03], ...
		'Tag', 'edit_mep_done_when', ...
		'String', '', 'fontsize', analysis_edit_fontsize);
	app.h_using_data_txt = uicontrol('Style', 'text', 'Units', 'normalized', ...
		'Position', [0.7828 0.1656 0.1388 0.0242], 'Fontsize', analysis_label_fontsize, ...
		'String', 'Using xx data', ...
		'HorizontalAlignment', 'left', 'Visible','off');
	app.h_show_analysis_meps = uicontrol('Style', 'pushbutton', ...
		'Units', 'normalized', 'Position', [0.7793,0.1244,0.181,0.0367], ...
		'Tag', 'show_analysis_meps_pushbutton', ...
		'String', 'Show MEPs used for analysis', 'fontsize', analysis_label_fontsize, 'Value', 0, ...
		'Callback', {@show_analysis_meps, app}, 'Visible','off');
    
	uicontrol('Style', 'text', 'Units', 'normalized', ...
		'Position', [0.6 0.1056 0.0647 0.02], 'Fontsize', large_button_fontsize, ...
		'String', 'Comments', ...
		'HorizontalAlignment', 'left')
	app.h_mep_analysis_comments = uicontrol('Style', 'edit', ...
		'Units', 'normalized', 'Position', [0.6 0.0722 0.3526 0.03], ...
		'Tag', 'edit_mep_analysis_comments', ...
        'HorizontalAlignment', 'left', ...
		'String', '', 'fontsize', analysis_edit_fontsize);
	uicontrol('Style', 'text', 'Units', 'normalized', ...
		'Position', [0.6 0.16 0.056 0.0367], 'Fontsize', large_button_fontsize, ...
		'String', 'MEP times analysis by:', ...
		'HorizontalAlignment', 'left')
	app.h_chkbx_mep_verified_by = uicontrol('Style', 'checkbox', ...
		'Units', 'normalized', 'Position', [0.6 0.0261 0.0733 0.03], ...
		'Tag', 'checkbox_mep_verified_by', ...
		'String', 'Verified by', 'fontsize', analysis_edit_fontsize, ...
		'Callback', {@chkbox_mep_verified_callback, app});
	app.h_edit_mep_verified_by = uicontrol('Style', 'edit', ...
		'Units', 'normalized', 'Position', [0.6726 0.0261 0.0421 0.03], ...
		'Tag', 'edit_mep_verified_by', ...
		'String', '', 'fontsize', analysis_edit_fontsize);
	app.h_edit_mep_verified_when = uicontrol('Style', 'edit', ...
		'Units', 'normalized', 'Position', [0.7241, 0.0261 0.1086 0.03], ...
		'Tag', 'edit_mep_verified_when', ...
		'String', '', 'fontsize', analysis_edit_fontsize);


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
	
	% pre-stim emg std dev line
	app.h_pre_stim_emg_pos_std_line = line(app.h_disp_emg_axes, ...
		app.h_disp_emg_axes.XLim, [1000 1000], 'Color', [0 0 0], 'LineStyle', '--', 'LineWidth', 2);
	app.h_pre_stim_emg_neg_std_line = line(app.h_disp_emg_axes, ...
		app.h_disp_emg_axes.XLim, [-1000 -1000], 'Color', [0 0 0], 'LineStyle', '--', 'LineWidth', 2);
	
	% emg auc line
	app.h_emg_auc_patch = patch(app.h_disp_emg_axes, ...
		[10 10 90 90], [10 100 100 10], [0.4 0.4 0.4]); 
	app.h_emg_auc_patch.FaceAlpha = 0.5;
	app.h_emg_auc_patch.Visible = 'off';

else % figure already exist, reset to defaults
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
	app.h_pre_stim_emg_pos_std_line.YData = [1000 1000];
	app.h_pre_stim_emg_neg_std_line.YData = [-1000 -1000];
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
	% rc plateau checkbox visible
	app.h_rc_plateau_checkbox.Visible = 'on';
	% create the recruitment curve figure
	init_rc_fig(app)
	if isgraphics(app.sici_fig)
		delete(app.sici_fig)
	end
elseif app.CheckBoxSici.Value == 1
	% ISI conditioning stim line
	app.h_cs_line.Visible = 'on';
	% rc plateau checkbox not needed
	app.h_rc_plateau_checkbox.Visible = 'off';
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