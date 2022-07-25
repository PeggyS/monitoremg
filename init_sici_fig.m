function init_sici_fig(app)
% create the figure showing Test Stim, SICI, ICF, and LICI

% if there is already a sici fig, clear old axes & fit info
if ~isempty(findobj('Tag', 'sici_icf_fig'))
	app.sici_axes;
	
% 	% clear any existing fit_info
% 	app.sici_info = [];
% 	% reset ui
% 	ylabel('MEP Vp-p (�V)')
% 	app.sici_info.edNormFactor.String = '1';
% 	app.sici_info.mean_ts.String = '0';
% 	app.sici_info.sd_ts.String = '0';
% 	app.sici_info.n_ts.String = '0';
% 	app.sici_info.mean_sici.String = '0';
% 	app.sici_info.sd_sici.String = '0';
% 	app.sici_info.n_sici.String = '0';
% 	app.sici_info.mean_icf.String = '';
% 	app.sici_info.sd_icf.String = '';
% 	app.sici_info.n_icf.String = '0';

% switch rb to default displaying MEP ampl 
	tag = find_selected_radio_button(app.h_radio_mep);
	switch tag
		case 'rb_mep_ampl'
			% do nothing
		case 'rb_mep_auc'
			% make rb_mep_ampl selected
			for c_cnt=1:length(app.h_radio_mep.Children)
				if contains(app.h_radio_mep.Children(c_cnt).Tag, 'rb_mep_ampl')
					app.h_radio_mep.Children(c_cnt).Value = 1;
				else
					app.h_radio_mep.Children(c_cnt).Value = 0;
				end
			end
% 			app.h_radio_mep.Children(rb_ind).Value = 0;
% 			app.h_radio_mep.Children(rb_other_ind).Value = 1;
			app.MmaxtoRCButton.Text = 'M-max to SICI';
			app.sici_axes.YLabel.String = 'MEP Vp-p (\muV)';
	end
	
else

	app.sici_fig = figure('Position', [1544 483 506 505], ...
		'NumberTitle', 'off', 'Name', 'SICI & ICF', ...
		'Tag', 'sici_icf_fig' , 'ToolBar', 'none', ...
        'CreateFcn', @movegui);
%  		'MenuBar', 'none');  %


	app.sici_axes = axes(app.sici_fig, 'Position', [0.16 0.3 0.775 0.6], ...
		'Fontsize', 20, 'xlim', [0.5 4.5], 'xtick', 1:4, 'xticklabel', {'TS', 'SICI', 'ICF', 'LICI'});
	ylabel('MEP Vp-p (\muV)')
	% xlabel('Stim Type')


	% userdata is a table with the data
	app.sici_axes.UserData = cell2table(cell(0,3), ...
		'VariableNames', {'Epoch', 'Use', 'MagStim_Setting'});

	% edit boxes for test & conditioning stim values
	uicontrol(app.sici_fig, 'Style', 'text', ...
				'String', 'TS', ...
				'Units', 'normalized', ...
				'Position', [0.31 0.015 0.05 0.06], ...
	 			'Fontsize', 16);
	app.sici_ui.ts = uicontrol(app.sici_fig, 'Style', 'edit', ...
				'Units', 'normalized', ...
				'Position', [0.36 0.019 0.1 0.06], ...
	 			'Fontsize', 16, ...
	 			'Callback', {@sici_edit_ts, app});
	uicontrol(app.sici_fig, 'Style', 'text', ...
				'String', 'CS', ...
				'Units', 'normalized', ...
				'Position', [0.48 0.015 0.05 0.06], ...
	 			'Fontsize', 16);
	app.sici_ui.cs = uicontrol(app.sici_fig, 'Style', 'edit', ...
				'Units', 'normalized', ...
				'Position', [0.53 0.019 0.1 0.06], ...
	 			'Fontsize', 16);
	
	% h = uicontrol(app.sici_fig, 'Style', 'pushbutton', ...
	% 			'String', 'Compute Mean & SD', ...
	% 			'Units', 'normalized', ...
	% 			'Position', [0.35 0.019 0.4 0.06], ...
	% 			'Fontsize', 16, ...
	% 			'Callback', {@sici_mean, app});

	% button to save datapoints
	uicontrol(app.sici_fig, 'Style', 'pushbutton', ...
				'String', 'Save', ...
				'Units', 'normalized', ...
				'Position', [0.78 0.019 0.15 0.06], ...
				'Fontsize', 16, ...
				'Tag', 'pushbutton', ...
				'Callback', {@save_and_close_sici, app});

	% button to print as png
	uicontrol(app.sici_fig, 'Style', 'pushbutton', ...
				'String', 'P', ...
				'Units', 'normalized', ...
				'Position', [0.95 0.03 0.04 0.04], ...
				'Fontsize', 8, ...
				'Callback', {@print_sici, app});
	
	
	% set a close function to save the data
 	app.sici_fig.CloseRequestFcn = {@save_and_close_sici, app};

	% popup menu to choose the type of stim being recorded - only valid when
	% recording data (runnin from emg_rc app)
	if any(strcmp(properties(app), 'sici_popmenu')) 
		app.sici_popmenu = uicontrol(app.sici_fig, 'style','popup', ...
			'string',{'Test Stim';'SICI';'ICF'}, ...
			'Units', 'normalized', ...
			'Position', [0.06 0.01 0.25 0.07], ...
			'FontSize', 16);
	end

	% push button to recalc data mean & ci after disabling data points
	app.sici_ui.pb_recalc = uicontrol(app.sici_fig, 'style','PushButton', ...
			'string',{'Recalc'}, ...
			'Units', 'normalized', ...
			'Position', [0.63 0.019 0.15 0.06], ...
			'FontSize', 16, ...
			'Callback', {@recalc_sici, app});
		
	% norm factor
	uicontrol(app.sici_fig, ...
		'Style', 'text', ...
		'String', 'Norm Factor', ...
		'Units', 'normalized', ...
		'Position', [0.04 0.28 0.149 0.04], ...
		'FontSize', 12);
	app.rc_fit_ui.edNormFactor = uicontrol(app.sici_fig, ...
		'Style', 'edit', ...
		'String', '1.0', ...
		'Units', 'normalized', ...
		'Position', [0.05 0.24 0.122 0.032], ...
		'FontSize', 12, ...
		'Callback', {@rc_change_norm_factor, app});
	% % mean
	uicontrol(app.sici_fig, ...
		'Style', 'text', ...
		'String', 'Mean', ...
		'Units', 'normalized', ...
		'Position', [0.04 0.19 0.149 0.04], ...
		'FontSize', 14);

	app.sici_ui.ts_mean = uicontrol(app.sici_fig, ...
		'Style', 'text', ...
		'String', '0', ...
		'Units', 'normalized', ...
		'Position', [0.22 0.19 0.122 0.04], ...
		'FontSize', 14);
	app.sici_ui.sici_mean = uicontrol(app.sici_fig, ...
		'Style', 'text', ...
		'String', '0', ...
		'Units', 'normalized', ...
		'Position', [0.49 0.19 0.122 0.04], ...
		'FontSize', 14);
	app.sici_ui.icf_mean = uicontrol(app.sici_fig, ...
		'Style', 'text', ...
		'String', '0', ...
		'Units', 'normalized', ...
		'Position', [0.75 0.19 0.122 0.04], ...
		'FontSize', 14);
	

	% % conf interval
	uicontrol(app.sici_fig, ...
		'Style', 'text', ...
		'String', '98% CI', ...
		'Units', 'normalized', ...
		'Position', [0.04 0.15 0.149 0.04], ...
		'FontSize', 14);

	app.sici_ui.ts_ci = uicontrol(app.sici_fig, ...
		'Style', 'text', ...
		'String', '[]', ...
		'Units', 'normalized', ...
		'Position', [0.18 0.15 0.25 0.04], ...
		'FontSize', 14);
	app.sici_ui.sici_ci = uicontrol(app.sici_fig, ...
		'Style', 'text', ...
		'String', '[]', ...
		'Units', 'normalized', ...
		'Position', [0.42 0.15 0.25 0.04], ...
		'FontSize', 14);
	app.sici_ui.icf_ci = uicontrol(app.sici_fig, ...
		'Style', 'text', ...
		'String', '[]', ...
		'Units', 'normalized', ...
		'Position', [0.70 0.15 0.25 0.04], ...
		'FontSize', 14);
	% % N
	uicontrol(app.sici_fig, ...
		'Style', 'text', ...
		'String', 'N', ...
		'Units', 'normalized', ...
		'Position', [0.04 0.11 0.149 0.04], ...
		'FontSize', 14);

	app.sici_ui.ts_n = uicontrol(app.sici_fig, ...
		'Style', 'text', ...
		'String', '0', ...
		'Units', 'normalized', ...
		'Position', [0.22 0.11 0.122 0.04], ...
		'FontSize', 14);
	app.sici_ui.sici_n = uicontrol(app.sici_fig, ...
		'Style', 'text', ...
		'String', '0', ...
		'Units', 'normalized', ...
		'Position', [0.49 0.11 0.122 0.04], ...
		'FontSize', 14);
	app.sici_ui.icf_n = uicontrol(app.sici_fig, ...
		'Style', 'text', ...
		'String', '0', ...
		'Units', 'normalized', ...
		'Position', [0.75 0.11 0.122 0.04], ...
		'FontSize', 14);
	
	app.sici_ui.ts_mline = line([0.7 1.3],[nan nan], 'LineWidth', 3, 'Color', [0 0.4470 0.7410]);
	app.sici_ui.ts_sdupline = line([0.7 1.3],[nan nan], 'LineWidth', 1, 'Color', [0.8 0.8 0.8], 'LineStyle', '--');
	app.sici_ui.ts_ciupline = line([0.7 1.3],[nan nan], 'LineWidth', 3, 'Color', [0 0.4470 0.7410], 'LineStyle', '--');
	app.sici_ui.ts_sddownline = line([0.7 1.3],[nan nan], 'LineWidth', 1, 'Color', [0.8 0.8 0.8], 'LineStyle', '--');
	app.sici_ui.ts_cidownline = line([0.7 1.3],[nan nan], 'LineWidth', 3, 'Color', [0 0.4470 0.7410], 'LineStyle', '--');
	
	app.sici_ui.sici_mline = line([1.7 2.3],[nan nan], 'LineWidth', 3, 'Color', [0 0.4470 0.7410]);
	app.sici_ui.sici_sdupline = line([1.7 2.3],[nan nan], 'LineWidth', 1, 'Color', [0.8 0.8 0.8], 'LineStyle', '--');
	app.sici_ui.sici_sddownline = line([1.7 2.3],[nan nan], 'LineWidth', 1, 'Color', [0.8 0.8 0.8], 'LineStyle', '--');
	app.sici_ui.sici_ciupline = line([1.7 2.3],[nan nan], 'LineWidth', 3, 'Color', [0 0.4470 0.7410], 'LineStyle', '--');
	app.sici_ui.sici_cidownline = line([1.7 2.3],[nan nan], 'LineWidth', 3, 'Color', [0 0.4470 0.7410], 'LineStyle', '--');

	app.sici_ui.icf_mline = line([2.7 3.3],[nan nan], 'LineWidth', 3, 'Color', [0 0.4470 0.7410]);
	app.sici_ui.icf_sdupline = line([2.7 3.3],[nan nan], 'LineWidth', 1, 'Color', [0.8 0.8 0.8], 'LineStyle', '--');
	app.sici_ui.icf_sddownline = line([2.7 3.3],[nan nan], 'LineWidth', 1, 'Color', [0.8 0.8 0.8], 'LineStyle', '--');
	app.sici_ui.icf_ciupline = line([2.7 3.3],[nan nan], 'LineWidth', 3, 'Color', [0 0.4470 0.7410], 'LineStyle', '--');
	app.sici_ui.icf_cidownline = line([2.7 3.3],[nan nan], 'LineWidth', 3, 'Color', [0 0.4470 0.7410], 'LineStyle', '--');

	app.sici_ui.lici_mline = line([3.7 4.3],[nan nan], 'LineWidth', 3, 'Color', [0 0.4470 0.7410]);
	app.sici_ui.lici_sdupline = line([3.7 4.3],[nan nan], 'LineWidth', 1, 'Color', [0.8 0.8 0.8], 'LineStyle', '--');
	app.sici_ui.lici_sddownline = line([3.7 4.3],[nan nan], 'LineWidth', 1, 'Color', [0.8 0.8 0.8], 'LineStyle', '--');
	app.sici_ui.lici_ciupline = line([3.7 4.3],[nan nan], 'LineWidth', 3, 'Color', [0 0.4470 0.7410], 'LineStyle', '--');
	app.sici_ui.lici_cidownline = line([3.7 4.3],[nan nan], 'LineWidth', 3, 'Color', [0 0.4470 0.7410], 'LineStyle', '--');

end

