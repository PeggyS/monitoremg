function save_computed_mep_info(~, ~, app)

% save info used to compute mep_begin
% save in the analysis folder with datapoints.csv file
save_file = strrep(app.DatapointsCSVEditField.Value, 'datapoints.csv', 'mep_computed_info.txt');
% if the current directory has '/data/' in it then change it
% '/analysis/' to save the output there
[save_loc, save_f, save_ext] = fileparts(save_file);
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
			% 				while save_loc==0
			% 					disp('Must choose a folder to save output.')
			% 					save_loc = uigetdir();
			% 				end
		end
	end
end

% remove rc or sici from the name
rc_or_sici = '';
if contains(save_f, 'rc_')
	rc_or_sici = 'rc';
	save_f = strrep(save_f, 'rc_', '');
elseif contains(save_f, 'sici_' )
	rc_or_sici = 'sici';
	save_f = strrep(save_f, 'sici_', '');
end

save_file = fullfile(save_loc, [save_f save_ext]);
app.mep_info.file_name = save_file;
app.mep_info.mep_beg_t = round(app.h_t_min_line.XData(1), 1);
app.mep_info.mep_end_t = round(app.h_t_max_line.XData(1), 1);

% get what epochs are selected from the h_uitable
jUIScrollPane = findjobj(app.h_uitable);
jUITable = jUIScrollPane.getViewport.getView;
j_now_selected_rows = jUITable.getSelectedRows; % selected rows - zero indexed (java)
assert(~isempty(j_now_selected_rows), 'save_computed_mep_info: no rows found selected in uitable')
selected_epochs = j_now_selected_rows + 1;
app.mep_info.epochs_used = selected_epochs;

% change initials to the current user
if isempty(app.h_edit_mep_done_by.String)
	app.h_edit_mep_done_by.String = upper(app.user_initials);
end
app.mep_info.analyzed_by = app.h_edit_mep_done_by.String;
app.mep_info.analyzed_when = app.h_edit_mep_done_when.String;
app.mep_info.using_rc_or_sici_data = rc_or_sici;
app.mep_info.comments = strrep(app.h_mep_analysis_comments.String, ' : ', ' - ');

% update string with 'using data'
app.h_using_data_txt.String = ['Using ' app.mep_info.using_rc_or_sici_data ' data'];

% write info to file
write_fit_info(save_file, app.mep_info)
fprintf('save_computed_mep_info: file\n %s\n with mep times = [%f %f]\n', save_file, ...
	app.mep_info.mep_beg_t, app.mep_info.mep_end_t)

return
end