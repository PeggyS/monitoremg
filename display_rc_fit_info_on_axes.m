function display_rc_fit_info_on_axes(app)


axes(app.rc_axes)
% remove old errLines if any
hErr = findobj(app.rc_axes, 'Tag', 'errLine');
if ~isempty(hErr), delete(hErr); end
hold on
% func = inline('p(3)./(1+exp(p(1)*(p(2)-x)))','p','x');
func = @(p,x) p(4) + (p(3)-p(4))./(1+exp(p(1)*(p(2)-x)));
% p = parameter vector: [slope m, S50, MEP-max, MEP-min]

y = func([app.rc_fit_info.slope, app.rc_fit_info.s50, app.rc_fit_info.mepMax, app.rc_fit_info.mepMin], ...
	app.rc_fit_info.stimLevels);
% hErr = errorbar(x,y,ci,ci);
hErr = line(app.rc_fit_info.stimLevels, y);
set(hErr, 'Tag', 'errLine', 'LineWidth', 3, 'Color', [0.8 0 0]);

app.rc_fit_ui.edNormFactor.String = num2str(app.rc_fit_info.norm_factor);

% app.rc_fit_ui.eqn_params = p;
app.rc_fit_ui.edSlope.String = num2str(round(app.rc_fit_info.slope, 2));
app.rc_fit_ui.txtSlopeCI.String = ['[' num2str(round(app.rc_fit_info.slopeCi(1) , 2)) ', ' ...
	num2str(round(app.rc_fit_info.slopeCi(2),2)) ']' ] ;
app.rc_fit_ui.edS50.String = num2str(round(app.rc_fit_info.s50));
app.rc_fit_ui.txtS50CI.String = ['[' num2str(round(app.rc_fit_info.s50Ci(1))) ', ' ...
	num2str(round(app.rc_fit_info.s50Ci(2))) ']' ] ;
app.rc_fit_ui.edMEPmax.String = num2str(round(app.rc_fit_info.mepMax, 2));
app.rc_fit_ui.txtMEPmaxCI.String = ['[' num2str(round(app.rc_fit_info.mepMaxCi(1), 2)) ', ' ...
	num2str(round(app.rc_fit_info.mepMaxCi(2), 2)) ']' ] ;
app.rc_fit_ui.edMEPmin.String = num2str(round(app.rc_fit_info.mepMin, 2));
app.rc_fit_ui.txtMEPminCI.String = ['[' num2str(round(app.rc_fit_info.mepMinCi(1), 2)) ', ' ...
	num2str(round(app.rc_fit_info.mepMinCi(2), 2)) ']' ] ;

% display S50 & m-max confidence intervals on the figure
h_ci_lines = findobj(app.rc_axes, 'Tag', 'ci_line');
if ~isempty(h_ci_lines), delete(h_ci_lines); end
if app.rc_fit_info.mepMaxCi(1) > app.rc_axes.YLim(1) && app.rc_fit_info.mepMaxCi(1) < app.rc_axes.YLim(2)
	h_ci_lines(1) = line([app.rc_axes.XLim(2)-diff(app.rc_axes.XLim)/5, app.rc_axes.XLim(2)], ...
		[app.rc_fit_info.mepMaxCi(1), app.rc_fit_info.mepMaxCi(1)]);
else
	h_ci_lines(1) = line(mean(app.rc_axes.XLim), mean(app.rc_axes.YLim), 'Visible', 'off');
end
if app.rc_fit_info.mepMaxCi(2) > app.rc_axes.YLim(1) && app.rc_fit_info.mepMaxCi(2) < app.rc_axes.YLim(2)
	h_ci_lines(2) = line([app.rc_axes.XLim(2)-diff(app.rc_axes.XLim)/5, app.rc_axes.XLim(2)], ...
		[app.rc_fit_info.mepMaxCi(2), app.rc_fit_info.mepMaxCi(2)]);
else
	h_ci_lines(2) = line(mean(app.rc_axes.XLim), mean(app.rc_axes.YLim), 'Visible', 'off');
end

if app.rc_fit_info.mepMinCi(1) > app.rc_axes.YLim(1) && app.rc_fit_info.mepMinCi(1) < app.rc_axes.YLim(2)
	h_ci_lines(3) = line([app.rc_axes.XLim(1)+diff(app.rc_axes.XLim)/5, app.rc_axes.XLim(1)], ...
		[app.rc_fit_info.mepMinCi(1), app.rc_fit_info.mepMinCi(1)]);
else
	h_ci_lines(3) = line(mean(app.rc_axes.XLim), mean(app.rc_axes.YLim), 'Visible', 'off');
end
if app.rc_fit_info.mepMinCi(2) > app.rc_axes.YLim(1) && app.rc_fit_info.mepMinCi(2) < app.rc_axes.YLim(2)
	h_ci_lines(4) = line([app.rc_axes.XLim(1)+diff(app.rc_axes.XLim)/5, app.rc_axes.XLim(1)], ...
		[app.rc_fit_info.mepMinCi(2), app.rc_fit_info.mepMinCi(2)]);
else
	h_ci_lines(4) = line(mean(app.rc_axes.XLim), mean(app.rc_axes.YLim), 'Visible', 'off');
end

if app.rc_fit_info.s50Ci(1) > app.rc_axes.XLim(1) && app.rc_fit_info.s50Ci(1) < app.rc_axes.XLim(2)
	h_ci_lines(5) = line([app.rc_fit_info.s50Ci(1), app.rc_fit_info.s50Ci(1)], ...
		[app.rc_axes.YLim(1) diff(app.rc_axes.YLim)/5]);
else
	h_ci_lines(5) = line(mean(app.rc_axes.XLim), mean(app.rc_axes.YLim), 'Visible', 'off');
end
if app.rc_fit_info.s50Ci(2) > app.rc_axes.XLim(1) && app.rc_fit_info.s50Ci(2) < app.rc_axes.XLim(2)
	h_ci_lines(6) = line([app.rc_fit_info.s50Ci(2), app.rc_fit_info.s50Ci(2)], ...
		[app.rc_axes.YLim(1) diff(app.rc_axes.YLim)/5]);
else
	h_ci_lines(6) = line(mean(app.rc_axes.XLim), mean(app.rc_axes.YLim), 'Visible', 'off');
end
if app.rc_fit_info.s50 > app.rc_axes.XLim(1) && app.rc_fit_info.s50 < app.rc_axes.XLim(2) % symbol at s_50
	h_ci_lines(7) = line(app.rc_fit_info.s50, app.rc_axes.YLim(1), 'Marker', '*', 'Markersize', 15);
else
	h_ci_lines(7) = line(0,0, 'Visible', 'off');
end
set(h_ci_lines, 'Tag', 'ci_line', 'Color', [0.7 0.5 0.2], 'LineWidth', 1.5)

% display R-squared value
app.rc_fit_ui.txtRsq.String = ['Rsq = ' num2str(round(app.rc_fit_info.Rsq,2))];

% remove old meanLine if any
hMean = findobj(app.rc_axes, 'Tag', 'meanLine');
if ~isempty(hMean), delete(hMean); end

line(app.rc_fit_info.stimLevels, app.rc_fit_info.aucMeanVals, 'Color', [0 0.7 0], 'Tag', 'meanLine');

app.rc_fit_ui.txtAUC.String = ['AUC = ' num2str(round(app.rc_fit_info.auc, 2))];

return
end