function print_rc(source, event, app)


set(app.sici_fig,'PaperOrientation', orient, ...
	'PaperUnits','inches', ...
	'PaperPosition', [0 0 7 8]);

% 	'PaperSize', [6 7], ..
fname = [strrep(app.sici_axes.Title.String, ' ', '_') '_sici.png'];


print(app.sici_fig, '-dpng', fname);
