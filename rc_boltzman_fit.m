function rc_boltzman_fit(source,event, app) %#ok<INUSL> 

% norm factor
norm_factor = str2double(app.rc_fit_ui.edNormFactor.String);

% mep begin & end lines
mep_begin = app.h_t_min_line.XData(1);
mep_end = app.h_t_max_line.XData(1);


stimulator = []; % stimulator & mode: magstim, bistim, simultaneous_discharge

% make provision for MEPAUC:
% find out if app is displaying MEP ampl or auc - currently only applies
% when using the review_emg app
[data_var, mep_method] = get_data_var_mep_method(app);

% Take into account BiStim - use effective stimulator output value
% in review_emg_rc.mlapp only. In emg_rc.mlapp, keep using the magstim setting.
% stimulator_mode: magstim, bistim, simultaneous_discharge

if isprop(app, 'EMGDisplayRCUIFigure') 
	% runnng in emg_rc.mlapp
	x_data = app.rc_axes.UserData.MagStim_Setting(logical(app.rc_axes.UserData.Use));
	stimulator_mode = 'bistim'; % default single pulse on the bistim setup
	if any(app.rc_axes.UserData.ISI_ms(logical(app.rc_axes.UserData.Use)) == 0)
		stimulator_mode = 'simultaneous_discharge';
	end

	y_data = (app.rc_axes.UserData.(data_var)(logical(app.rc_axes.UserData.Use))) / norm_factor;

else
	% running in review_emg_rc.mlapp
	use_ind = find(contains(app.h_uitable.ColumnName, 'use', 'IgnoreCase', true));
	effective_so_ind = find(contains(app.h_uitable.ColumnName, '>effective<', 'IgnoreCase', true));
	use_msk = cell2mat(app.h_uitable.Data(:,use_ind));
	x_data = cell2mat(app.h_uitable.Data(use_msk, effective_so_ind));

	% from the data_var, generate the unique part of h_uitable's column name
	reg_result = regexp(data_var, '(?<first>[^_]*)_(?<units>.*)', 'names');
	% returns:
	% 	first: 'MEPAmpl'
	%   units: 'uVPp'
	% or
	% 	first: 'MEPAUC'
	%   units: 'uV_ms'
	table_var = ['>' reg_result.first '<'];
	y_data_ind = find(contains(app.h_uitable.ColumnName, table_var, 'IgnoreCase', true));
	y_data = cell2mat(app.h_uitable.Data(use_msk, y_data_ind)) / norm_factor;

	% from the magstim and bistim values in the table, determine the
	% stimulator_mode
	stimulator_setup = app.h_stim_setup_text.String;
	if strcmpi(stimulator_setup, 'bistim')
		magstim_ind = find(contains(app.h_uitable.ColumnName, '>MagStim<', 'IgnoreCase', true));
		bistim_ind = find(contains(app.h_uitable.ColumnName, '>BiStim<', 'IgnoreCase', true));
		magstim_equals_bistim = cell2mat(app.h_uitable.Data(use_msk, magstim_ind)) == ...
			cell2mat(app.h_uitable.Data(use_msk, bistim_ind));
		if all(magstim_equals_bistim)
			stimulator_mode = 'simultaneous_discharge';
		elseif all(cell2mat(app.h_uitable.Data(use_msk, bistim_ind)) == 0)
			stimulator_mode = 'bistim';
		else
% 			keyboard
			stimulator_mode = 'mixed_bistim_and_simultaneous_discharge';
		end
	else
		stimulator_mode = 'magstim';
	end
end


% the sigmoid function with 4 parameters to fit
% func = inline('p(3)./(1+exp(p(1)*(p(2)-x)))','p','x');
func = @(p,x) p(4) + (p(3)-p(4))./(1+exp(p(1)*(p(2)-x)));

% p = parameter vector: [slope m, S50, MEP-max, MEP-min]

% change initial parameter for MEPmax depending on the axis limits
if isempty(app.rc_fit_ui.edMEPmax.String) || contains(app.rc_fit_ui.edMEPmax.String, 'nan', 'IgnoreCase',true)
	ax_ymax = max(app.rc_axes.YLim);
	app.rc_fit_ui.edMEPmax.String = num2str(0.75*ax_ymax);
end

% initial parameter guess
p0 = [str2double(app.rc_fit_ui.edSlope.String), ...
	str2double(app.rc_fit_ui.edS50.String), ...
	str2double(app.rc_fit_ui.edMEPmax.String), ...
	str2double(app.rc_fit_ui.edMEPmin.String)];

options = statset('nlinfit');
options = statset(options, 'MaxIter', 1e4);

% fit the y_data curve using x_data and p0 as inputs to 'func' 
[p,r,j,covb,mse] = nlinfit(x_data, y_data, func, p0, options ); %#ok<ASGLU> 

% x values for plotting lines
x = unique(x_data);

% confidence intervals using x, p as inputs to 'func'
[yp, ci] = nlpredci(func,x,p,r,j); %#ok<ASGLU> 

% parameter confidence intervals
pci = nlparci(p, r, 'jacobian', j);

axes(app.rc_axes)
% remove old errLines if any
hErr = findobj(app.rc_axes, 'Tag', 'errLine');
if ~isempty(hErr), delete(hErr); end
hold on
y = func(p,x);
hErr = errorbar(x,y,ci,ci);
set(hErr, 'Tag', 'errLine', 'LineWidth', 3, 'Color', [0.8 0 0]);


% app.rc_fit_ui.txtSlope.String = num2str(p(1));
% app.rc_fit_ui.txtSlopeCI1.String = ['[' num2str(pci(1,1))];
% app.rc_fit_ui.txtSlopeCI2.String = [ num2str(pci(1,2)) ']' ] ;
% app.rc_fit_ui.txtS50.String = num2str(p(2));
% app.rc_fit_ui.txtS50CI1.String = ['[' num2str(pci(2,1)) ] ;
% app.rc_fit_ui.txtS50CI2.String = [ num2str(pci(2,2)) ']' ] ;
% app.rc_fit_ui.txtMEPmax.String = num2str(p(3));
% app.rc_fit_ui.txtMEPmaxCI1.String = ['[' num2str(pci(3,1))  ] ;
% app.rc_fit_ui.txtMEPmaxCI2.String = [ num2str(pci(3,2)) ']' ] ;
app.rc_fit_ui.eqn_params = p;
app.rc_fit_ui.edSlope.String = num2str(round(p(1), 2));
app.rc_fit_ui.txtSlopeCI.String = ['[' num2str(round(pci(1,1), 2)) ', ' num2str(round(pci(1,2),2)) ']' ] ;
app.rc_fit_ui.edS50.String = num2str(round(p(2)));
app.rc_fit_ui.txtS50CI.String = ['[' num2str(round(pci(2,1))) ', ' num2str(round(pci(2,2))) ']' ] ;
app.rc_fit_ui.edMEPmax.String = num2str(round(p(3), 2));
app.rc_fit_ui.txtMEPmaxCI.String = ['[' num2str(round(pci(3,1), 2)) ', ' num2str(round(pci(3,2), 2)) ']' ] ;
app.rc_fit_ui.edMEPmin.String = num2str(round(p(4), 2));
app.rc_fit_ui.txtMEPminCI.String = ['[' num2str(round(pci(4,1), 2)) ', ' num2str(round(pci(4,2), 2)) ']' ] ;

% display S50 & m-max confidence intervals on the figure
h_ci_lines = findobj(app.rc_axes, 'Tag', 'ci_line');
if ~isempty(h_ci_lines), delete(h_ci_lines); end
if pci(3,1) > app.rc_axes.YLim(1) && pci(3,1) < app.rc_axes.YLim(2)
	h_ci_lines(1) = line([app.rc_axes.XLim(2)-diff(app.rc_axes.XLim)/5, app.rc_axes.XLim(2)], [pci(3,1), pci(3,1)]);
else
	h_ci_lines(1) = line(mean(app.rc_axes.XLim), mean(app.rc_axes.YLim), 'Visible', 'off');
end
if pci(3,2) > app.rc_axes.YLim(1) && pci(3,2) < app.rc_axes.YLim(2)
	h_ci_lines(2) = line([app.rc_axes.XLim(2)-diff(app.rc_axes.XLim)/5, app.rc_axes.XLim(2)], [pci(3,2), pci(3,2)]);
else
	h_ci_lines(2) = line(mean(app.rc_axes.XLim), mean(app.rc_axes.YLim), 'Visible', 'off');
end

if pci(4,1) > app.rc_axes.YLim(1) && pci(4,1) < app.rc_axes.YLim(2)
	h_ci_lines(3) = line([app.rc_axes.XLim(1)+diff(app.rc_axes.XLim)/5, app.rc_axes.XLim(1)], [pci(4,1), pci(4,1)]);
else
	h_ci_lines(3) = line(mean(app.rc_axes.XLim), mean(app.rc_axes.YLim), 'Visible', 'off');
end
if pci(4,2) > app.rc_axes.YLim(1) && pci(4,2) < app.rc_axes.YLim(2)
	h_ci_lines(4) = line([app.rc_axes.XLim(1)+diff(app.rc_axes.XLim)/5, app.rc_axes.XLim(1)], [pci(4,2), pci(4,2)]);
else
	h_ci_lines(4) = line(mean(app.rc_axes.XLim), mean(app.rc_axes.YLim), 'Visible', 'off');
end

if pci(2,1) > app.rc_axes.XLim(1) && pci(2,1) < app.rc_axes.XLim(2)
	h_ci_lines(5) = line([pci(2,1), pci(2,1)], [app.rc_axes.YLim(1) diff(app.rc_axes.YLim)/5]);
else
	h_ci_lines(5) = line(mean(app.rc_axes.XLim), mean(app.rc_axes.YLim), 'Visible', 'off');
end
if pci(2,2) > app.rc_axes.XLim(1) && pci(2,2) < app.rc_axes.XLim(2)
	h_ci_lines(6) = line([pci(2,2), pci(2,2)], [app.rc_axes.YLim(1) diff(app.rc_axes.YLim)/5]);
else
	h_ci_lines(6) = line(mean(app.rc_axes.XLim), mean(app.rc_axes.YLim), 'Visible', 'off');
end
if p(2) > app.rc_axes.XLim(1) && p(2) < app.rc_axes.XLim(2) % symbol at s_50
	h_ci_lines(7) = line(p(2), app.rc_axes.YLim(1), 'Marker', '*', 'Markersize', 15);
else
	h_ci_lines(7) = line(0,0, 'Visible', 'off');
end
set(h_ci_lines, 'Tag', 'ci_line', 'Color', [0.7 0.5 0.2], 'LineWidth', 1.5)

% calc R-squared (used method from the polyfit example in matlab)
SSresid = sum(r.^2);			%% residual sum of squares
nobs = max(size(y_data));			% number of observations
SStotal = (nobs-1) * var(y_data);	%% total sum of squares: variance of y * num observations -1
Rsq = 1 - SSresid/SStotal;		%% R-squared
	
% display R-squared value
app.rc_fit_ui.txtRsq.String = ['Rsq = ' num2str(round(Rsq,2))];

% also compute the mean MEP at each stim level and the area under the mean curve
stimLevels = unique(x_data);

meanY = nan(size(stimLevels));
% mean at each stim level
for st = 1:length(stimLevels)
	meanY(st) = mean(y_data(x_data==stimLevels(st)), 'omitnan');
end
% remove old meanLine if any
hMean = findobj(app.rc_axes, 'Tag', 'meanLine');
if ~isempty(hMean), delete(hMean); end

line(stimLevels, meanY, 'Color', [0 0.7 0], 'Tag', 'meanLine');
% area under the curve
auc = polyarea([stimLevels(1); stimLevels; stimLevels(end)], ...
				[0; meanY; 0]);
app.rc_fit_ui.txtAUC.String = ['AUC = ' num2str(round(auc, 2))];

% info saved in app struct for easy saving
app.rc_fit_info.mepMethod = mep_method;
app.rc_fit_info.norm_factor = norm_factor;
app.rc_fit_info.mep_beg_t = mep_begin;
app.rc_fit_info.mep_end_t = mep_end;
app.rc_fit_info.slope = p(1);
app.rc_fit_info.s50 = p(2);
app.rc_fit_info.mepMin = p(4);
app.rc_fit_info.mepMax = p(3);
app.rc_fit_info.slopeCi = pci(1,1:2);
app.rc_fit_info.s50Ci = pci(2,1:2);
app.rc_fit_info.mepMinCi = pci(4,1:2);
app.rc_fit_info.mepMaxCi = pci(3,1:2);
app.rc_fit_info.Rsq = Rsq;
app.rc_fit_info.auc = auc;
app.rc_fit_info.aucMeanVals = meanY;
app.rc_fit_info.stimLevels = stimLevels;
app.rc_fit_info.stimulator_mode = stimulator;
app.rc_fit_info.stimulator_mode = stimulator_mode;
return