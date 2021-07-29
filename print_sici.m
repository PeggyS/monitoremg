function print_sici(source, event, app)
cur_dir = pwd;

if ~any(strcmp(properties(app), 'SaveLocationEditField')) 
	% review_emg_rc app has no property for save location
	[pname, ~, ~] = fileparts(app.EMGDataTxtEditField.Value);
	save_loc = pname;
	% if the current directory has '/data/' in it then change it
	% '/analysis/' to save the output there
	if contains(save_loc, '/data/', 'IgnoreCase', true)
		save_loc = strrep(save_loc, '/data/', '/analysis/');
		% ask to create the folder if it doesn't exist
		if ~exist(save_loc, 'dir')
			ButtonName = questdlg(['Create new directory: ' save_loc ' ?'], ...
                         'Create new directory', ...
                         'Yes', 'No', 'Yes');
			if strcmp(ButtonName, 'Yes')
				[success, msg, msg_id] = mkdir(save_loc);
			else
				disp('Choose where to save output')
				save_loc = uigetdir();
			end
		end
	end
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

% determine mep method
[~, mep_method] = get_data_var_mep_method(app);

set(app.sici_fig,'PaperOrientation', orient, ...
	'PaperUnits','inches', ...
	'PaperPosition', [0 0 7 8]);

% 	'PaperSize', [6 7], ..
fname = [save_loc '/' fname_prefix strrep(app.sici_axes.Title.String, ' ', '_') '_' mep_method '_sici.png'];


print(app.sici_fig, '-dpng', fname);
