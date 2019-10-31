function print_rc(source, event, app)
cur_dir = pwd;

if ~any(strcmp(properties(app), 'SaveLocationEditField')) 
	% review_emg_rc app has no property for save location
	save_loc = cur_dir;
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


set(app.rc_fig,'PaperOrientation', orient, ...
	'PaperUnits','inches', ...
	'PaperPosition', [0 0 7 8]);

% 	'PaperSize', [6 7], ..
% add mep method to fname
if isfield(app.rc_fit_info, 'mepMethod')
	fname = [save_loc '/' fname_prefix strrep(app.rc_axes.Title.String, ' ', '_') '_' app.rc_fit_info.mepMethod '_rc_not_norm.png'];
else
	fname = [save_loc '/' fname_prefix strrep(app.rc_axes.Title.String, ' ', '_') '_rc_not_norm.png'];
end

% if norm value > 1, change not_norm to norm in fitinfo_fname
if str2double(app.rc_fit_ui.edNormFactor.String) > 1
	fname = strrep(fname, '_not_norm', '_norm');
end

print(app.rc_fig, '-dpng', fname);
