function rc_boltzman_fit(source,event, app)

% norm factor
norm_factor = str2double(app.rc_fit_ui.edNormFactor.String);

% the data
x_data = app.rc_axes.UserData.MagStim_Setting(logical(app.rc_axes.UserData.Use));
% make provision for MEPAUC:
% find out if app is displaying MEP ampl or auc
if isprop(app, 'h_radio_mep')
	for kk = 1:length(app.h_radio_mep.Children)
		if app.h_radio_mep.Children(kk).Value
			tag = app.h_radio_mep.Children(kk).Tag; % tag of selected radio button (either rb_mep_pp, or rb_mep_auc)
		end
	end
end
switch tag
	case 'rb_mep_pp'
		data_var = 'MEPAmpl_uVPp';
	case 'rb_mep_auc'
		data_var = 'MEPAUC_uV_ms';
end
y_data = (app.rc_axes.UserData.(data_var)(logical(app.rc_axes.UserData.Use))) / norm_factor;

% the sigmoid function with 3 parameters to fit
% func = inline('p(3)./(1+exp(p(1)*(p(2)-x)))','p','x');
func = @(p,x) p(4) + (p(3)-p(4))./(1+exp(p(1)*(p(2)-x)));

% p = parameter vector: [slope m, S50, MEP-max, MEP-min]

% change initial parameter for MEPmax depending on the axis limits
if isempty(app.rc_fit_ui.edMEPmax.String)
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

% fit the curve
[p,r,j,covb,mse] = nlinfit(x_data, y_data, func, p0, options );

% x values for plotting lines
x = unique(x_data);

% confidence intervals
[yp, ci] = nlpredci(func,x,p,r,j);
axes(app.rc_axes)
% remove old errLines if any
hErr = findobj(app.rc_axes, 'Tag', 'errLine');
if ~isempty(hErr), delete(hErr); end
hold on
y = func(p,x);
hErr = errorbar(x,y,ci,ci);
set(hErr, 'Tag', 'errLine', 'LineWidth', 3, 'Color', [0.8 0 0]);

% parameter confidence intervals
pci = nlparci(p, r, 'jacobian', j);

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
	meanY(st) = nanmean(y_data(x_data==stimLevels(st)));
end
% remove old meanLine if any
hMean = findobj(app.rc_axes, 'Tag', 'meanLine');
if ~isempty(hMean), delete(hMean); end

hMean = line(stimLevels, meanY, 'Color', [0 0.7 0], 'Tag', 'meanLine');
% area under the curve
auc = polyarea([stimLevels(1); stimLevels; stimLevels(end)], ...
				[0; meanY; 0]);
app.rc_fit_ui.txtAUC.String = ['AUC = ' num2str(round(auc, 2))];

% info saved in app struct for easy saving
app.rc_fit_info.mepMethod = 'p2p';
app.rc_fit_info.norm_factor = norm_factor;
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
return