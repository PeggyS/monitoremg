function view_sici_vals(fname)

% vals = load(fname);
tbl = readtable(fname);
tbl.Sici_or_icf_or_ts = nominal(tbl.Sici_or_icf_or_ts);

% figure('Position', [1142         906         882         439])
figure('Position', [904   722   771   534]);
% h_ax = axes('FontSize', 14);
% title(strrep(fname, '_', '\_'))

stim_type_list = unique(tbl.Sici_or_icf_or_ts, 'stable');
for s_cnt = 1:length(stim_type_list)
	h_ax = subplot(length(stim_type_list), 1, s_cnt);
	h_ax.FontSize = 14;
	
	vals = table2array(tbl(tbl.Sici_or_icf_or_ts == stim_type_list(s_cnt), {'MEPAmpl_uVPp'}));

	% the mep values
	x = 1:length(vals);
	h_l = line(x, vals, 'Marker', 'o', 'MarkerSize', 12, 'LineStyle', 'none');
	h_l.MarkerFaceColor = h_l.Color;
	hold on
	
	ylabel({char(stim_type_list(s_cnt)) 'MEP (µV)'})

	% show mean & ci for all samples up to the Nth sample

	for n = 3:length(vals)
		sample_mean = mean(vals(1:n));
		sample_ci = confidence_intervals(vals(1:n), 98);
		line([n-0.5 n+0.5], [sample_mean sample_mean], 'LineWidth', 3);
		line([n-0.5 n+0.5], [sample_mean+sample_ci(1) sample_mean+sample_ci(1)], 'LineStyle', ':', 'LineWidth', 3);
		line([n-0.5 n+0.5], [sample_mean+sample_ci(2) sample_mean+sample_ci(2)], 'LineStyle', ':', 'LineWidth', 3);
	end

	h_ax.XLim = [0 length(vals)+1];

	h_t = title( ['mean = ' num2str(sample_mean,'%15.1f') ...
		' [' num2str(sample_mean+sample_ci(1),'%15.1f') '  ' num2str(sample_mean+sample_ci(2),'%15.1f') ']'], ...
		'FontSize', 12);

	% draggable(h_t, 'endfcn', @myresume)
	% uiwait
	% 
	% print(strrep(fname, '.txt', '.png'), '-dpng')

end
xlabel('N Samples')


function myresume(hfig)
uiresume
return