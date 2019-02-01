function view_sici_vals(fname)

vals = load(fname);

figure('Position', [1142         906         882         439])
h_ax = axes('FontSize', 14);
title(strrep(fname, '_', '\_'))


% the mep values
x = 1:length(vals);
h_l = line(x, vals, 'Marker', 'o', 'MarkerSize', 12, 'LineStyle', 'none');
h_l.MarkerFaceColor = h_l.Color;
hold on
xlabel('N Samples')
ylabel('MEP (µV)')

% show mean & ci for all samples up to the Nth sample

for n = 3:length(vals)
	sample_mean = mean(vals(1:n));
	sample_ci = confidence_intervals(vals(1:n), 98);
	line([n-0.5 n+0.5], [sample_mean sample_mean], 'LineWidth', 3);
	line([n-0.5 n+0.5], [sample_mean+sample_ci(1) sample_mean+sample_ci(1)], 'LineStyle', ':', 'LineWidth', 3);
	line([n-0.5 n+0.5], [sample_mean+sample_ci(2) sample_mean+sample_ci(2)], 'LineStyle', ':', 'LineWidth', 3);
end

h_ax.XLim = [0 length(vals)+1];

h_t = text(mean(h_ax.XLim), mean(h_ax.YLim), ['mean = ' num2str(sample_mean,'%15.1f') ...
	' [' num2str(sample_mean+sample_ci(1),'%15.1f') '  ' num2str(sample_mean+sample_ci(2),'%15.1f') ']'], ...
	'FontSize', 12);

draggable(h_t, 'endfcn', @myresume)
uiwait

print(strrep(fname, '.txt', '.png'), '-dpng')

function myresume(hfig)
uiresume
return