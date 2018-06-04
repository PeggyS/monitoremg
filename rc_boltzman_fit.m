function rc_boltzman_fit(source,event, app)
% the data
x_data = app.rc_axes.UserData.MagStim_Setting(logical(app.rc_axes.UserData.Use));
y_data = app.rc_axes.UserData.MEPAmpl_uVPp(logical(app.rc_axes.UserData.Use));

% the sigmoid function with 3 parameters to fit
func = inline('p(3)./(1+exp(p(1)*(p(2)-x)))','p','x');

% p = parameter vector: [slope m, S50, MEP-max]

% initial parameter guess
p0 = [str2double(app.rc_fit_info.edSlope.String), ...
	str2double(app.rc_fit_info.edS50.String), ...
	str2double(app.rc_fit_info.edMEPmax.String)];

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
hErr = errorbar(x,func(p,x),ci,ci,'m-');
set(hErr, 'Tag', 'errLine');

% parameter confidence intervals
pci = nlparci(p, r, 'jacobian', j);

app.rc_fit_info.txtSlope.String = num2str(p(1));
app.rc_fit_info.txtSlopeCI1.String = ['[' num2str(pci(1,1))];
app.rc_fit_info.txtSlopeCI2.String = [ num2str(pci(1,2)) ']' ] ;
app.rc_fit_info.txtS50.String = num2str(p(2));
app.rc_fit_info.txtS50CI1.String = ['[' num2str(pci(2,1)) ] ;
app.rc_fit_info.txtS50CI2.String = [ num2str(pci(2,2)) ']' ] ;
app.rc_fit_info.txtMEPmax.String = num2str(p(3));
app.rc_fit_info.txtMEPmaxCI1.String = ['[' num2str(pci(3,1))  ] ;
app.rc_fit_info.txtMEPmaxCI2.String = [ num2str(pci(3,2)) ']' ] ;

% calc R-squared (used method from the polyfit example in matlab)
SSresid = sum(r.^2);			%% residual sum of squares
nobs = max(size(y_data));			% number of observations
SStotal = (nobs-1) * var(y_data);	%% total sum of squares: variance of y * num observations -1
Rsq = 1 - SSresid/SStotal;		%% R-squared
	
% display R-squared value
app.rc_fit_info.txtRsq.String = ['Rsq = ' num2str(Rsq)];

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

hMean = line(stimLevels, meanY, 'Color', 'g', 'Tag', 'meanLine');
% area under the curve
auc = polyarea([stimLevels(1); stimLevels; stimLevels(end)], ...
				[0; meanY; 0]);
app.rc_fit_info.txtAUC.String = ['AUC = ' num2str(auc)];


return