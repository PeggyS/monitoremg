function print_rc(source, event, app)

if ~any(strcmp(properties(app), 'SaveLocationEditField')) 
	save_loc = pwd;
	fname_prefix = '';
else
	if isempty(app.SaveLocationEditField.Value)
		app.SaveLocationEditField.Value = pwd;
		save_loc = pwd;
	else
		save_loc = app.SaveLocationEditField.Value;
	end
	fname_prefix = app.EditFieldFilenameprefix.Value;
end

set(app.sici_fig,'PaperOrientation', orient, ...
	'PaperUnits','inches', ...
	'PaperPosition', [0 0 7 8]);

% 	'PaperSize', [6 7], ..
fname = [save_loc '/' fname_prefix strrep(app.sici_axes.Title.String, ' ', '_') '_sici.png'];


print(app.sici_fig, '-dpng', fname);
