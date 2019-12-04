function view_sici_vals(fname)

% vals = load(fname);
tbl = readtable(fname);
tbl.Stim_Type = nominal(tbl.Stim_Type);

% figure('Position', [1142         906         882         439])
figure('Position', [904   722   771   534]);
% h_ax = axes('FontSize', 14);
% title(strrep(fname, '_', '\_'))

stim_type_list = unique(tbl.Stim_Type, 'stable');
for s_cnt = 1:length(stim_type_list)
	h_ax = subplot(length(stim_type_list), 1, s_cnt);
	h_ax.FontSize = 14;
	yyaxis(h_ax, 'left')
	
	vals = table2array(tbl(tbl.Stim_Type == stim_type_list(s_cnt), {'MEPAmpl_uVPp'}));

	% the mep values
	x = 1:length(vals);
	h_l = line(h_ax(1), x, vals, 'Marker', 'o', 'MarkerSize', 12, 'LineStyle', 'none');
	h_l.MarkerFaceColor = h_l.Color;
	hold on
	
	ylabel({char(stim_type_list(s_cnt)) 'MEP (µV)'})

	h_ax.XLim = [0 length(vals)+1];
	
	% show mean & ci for all samples up to the Nth sample
	for n = 3:length(vals)
		sample_mean = mean(vals(1:n));
		sample_ci = confidence_intervals(vals(1:n), 98);
		line(h_ax, [n-0.5 n+0.5], [sample_mean sample_mean], 'LineWidth', 3);
		line(h_ax, [n-0.5 n+0.5], [sample_mean+sample_ci(1) sample_mean+sample_ci(1)], 'LineStyle', ':', 'LineWidth', 3);
		line(h_ax, [n-0.5 n+0.5], [sample_mean+sample_ci(2) sample_mean+sample_ci(2)], 'LineStyle', ':', 'LineWidth', 3);
	end

	% on right axes show %change in conf interval
	yyaxis(h_ax, 'right')
	pct_change_in_ci = nan(1,length(vals));
	for n = 6:length(vals)
		ci_sample_n = confidence_intervals(vals(1:n), 98);
		ci_sample_n_minus_3 = confidence_intervals(vals(1:n-3), 98);
		ci_sample_n_minus_1 = confidence_intervals(vals(1:n-1), 98);
		ci_1 = diff(ci_sample_n_minus_3);
		ci_2 = diff(ci_sample_n);
		pct_change_in_ci(n) = abs((ci_1 - ci_2))/ci_1 * 100;
	end
	line(1:length(vals), pct_change_in_ci)
	ylabel('% change in ci')
	h_ax.YLim = [0 50];
	
	tlt_str = ['mean = ' num2str(sample_mean,'%15.1f') ...
		' [' num2str(sample_mean+sample_ci(1),'%15.1f') '  ' num2str(sample_mean+sample_ci(2),'%15.1f') ']'];
	if s_cnt == 1
		xtra_title = strrep(fname, '_', ' ');
		xtra_title = strrep(xtra_title, 'datapoints.csv', '');
		tlt_str = {xtra_title tlt_str};
	end
	h_t = title( tlt_str, 'FontSize', 12);

	% draggable(h_t, 'endfcn', @myresume)
	% uiwait
	% 
	% print(strrep(fname, '.txt', '.png'), '-dpng')

end
xlabel('N Samples')
% orient tall
% print([xtra_title ' samples.png'], '-dpng')

function myresume(hfig)
uiresume
return