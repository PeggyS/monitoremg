function fname = get_rc_fit_info_file_name(app)

% starting from datapoints file name, reconstruct what the rc fit info file
% name should be
[save_loc, starting_f_name, ~] = fileparts(app.DatapointsCSVEditField.Value);

% make sure it's in the analysis hierarchy
if contains(save_loc, [filesep 'data' filesep], 'IgnoreCase', true)
    save_loc = strrep(lower(save_loc), [filesep 'data' filesep], [filesep 'analysis' filesep]);
    % ask to create the folder if it doesn't exist
    if ~exist(save_loc, 'dir')
        ButtonName = questdlg(['Create new directory: ' save_loc ' ?'], ...
            'Create new directory', ...
            'Yes', 'No', 'Yes');
        if strcmp(ButtonName, 'Yes')
            [success, msg, msg_id] = mkdir(save_loc); %#ok<ASGLU>
        else
            disp('Choose where to save output')
            save_loc = uigetdir();
        end
    end
end

% find out if app is displaying MEP ampl or auc
[~, mep_method] = get_data_var_mep_method(app);

fit_info_fname = strrep(starting_f_name, 'rc_datapoints',  mep_method);
if str2double(app.rc_fit_ui.edNormFactor.String) > 1
	norm_str = '_fit_info_norm.txt';
else
	norm_str = '_fit_info_not_norm.txt';
end
fit_info_fname = [fit_info_fname norm_str];

fname = fullfile(save_loc, fit_info_fname);
return
end