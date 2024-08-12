function save_emg_trace(~, ~, app)

% keyboard

% path to save the figure
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

% file name
fname = strrep(starting_f_name, '_datapoints',  ['_epoch_' app.h_edit_epoch.String '.png']);

% save the emg data axes
fignew = figure('Position', [936   912   768   425], 'Visible', 'off'); % Invisible figure
newAxes = copyobj(app.h_disp_emg_axes, fignew); % Copy the axes to the figure
set(newAxes, 'Position', get(groot,'DefaultAxesPosition')); % The original position is copied too, so adjust it.
set(fignew, 'CreateFcn', 'set(gcbf,''Visible'',''on'')'); % Make it visible upon loading



print(fignew, '-dpng', fullfile(save_loc, fname));

delete(fignew);

end % function