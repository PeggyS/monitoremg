function get_previous_rc_or_sici_info(app)

if app.CheckBoxRc.Value == 1
	fname = get_rc_fit_info_file_name(app);
	app.rc_fit_info = read_fit_info(fname);
	% display the info
	if isfield(app.rc_fit_info, 'analyzed_by')
		app.AnalyzedbyEditField.Value = upper(app.rc_fit_info.analyzed_by);
	else
		app.AnalyzedbyEditField.Value = '???';
	end
	if isfield(app.rc_fit_info, 'analyzed_when')
		app.AnalyzedWhenEditField.Value = app.rc_fit_info.analyzed_when;
	else
		app.AnalyzedWhenEditField.Value = '2022-00-00';
	end
	% if norm factor in the file does not agree with the value in the rc
	% figure field
	if isfield(app.rc_fit_info,'norm_factor') && ...
			abs(app.rc_fit_info.norm_factor - str2double(app.rc_fit_ui.edNormFactor.String)) > eps
		msg = ['Norm factor in app does not agree with norm factor read in from saved file.' ...
			 ' Use ' app.rc_fit_ui.edNormFactor.String ' from Review EMG RC app or ' ...
			 num2str(app.rc_fit_info.norm_factor) ' from saved file?'];
		selection = uiconfirm(app.ReviewEMGRCUIFigure, msg, 'Norm Factor', 'Options', ...
			{app.rc_fit_ui.edNormFactor.String, num2str(app.rc_fit_info.norm_factor)});
		if contains(selection, app.rc_fit_ui.edNormFactor.String)
			app.rc_fit_info.norm_factor = str2double(app.rc_fit_ui.edNormFactor.String);
% 			keyboard
		end
	end
	if isfield(app.rc_fit_info, 'slope')
		display_rc_fit_info_on_axes(app)
	end
end % rc


if app.CheckBoxSici.Value == 1
	fname = get_rc_fit_info_file_name(app);
	fname = strrep(fname, '_fit_', '_sici_');
	read_in_info = read_sici_info(fname);
	% display the info
% 	if isfield(read_in_info, 'ts_n')
% 		% put latency info in the sici figure
% 		app.sici_ui.ts_latency.String = num2str(read_in_info.ts_mep_beg_t);
% 		app.sici_ui.ts_latency.UserData.mep_beg_t = read_in_info.ts_mep_beg_t;
% 		app.sici_ui.ts_latency.UserData.mep_end_t = read_in_info.ts_mep_end_t;
% 		app.sici_ui.ts_latency.UserData.epochs_used = read_in_info.ts_epochs_used;
% 		app.sici_ui.ts_latency.UserData.num_sd = read_in_info.ts_num_sd;
% 		app.sici_ui.sici_latency.String = num2str(read_in_info.sici_mep_beg_t);
% 		app.sici_ui.sici_latency.UserData.mep_beg_t = read_in_info.sici_mep_beg_t;
% 		app.sici_ui.sici_latency.UserData.mep_end_t = read_in_info.sici_mep_end_t;
% 		app.sici_ui.sici_latency.UserData.epochs_used = read_in_info.sici_epochs_used;
% 		app.sici_ui.sici_latency.UserData.num_sd = read_in_info.sici_num_sd;
% 		app.sici_ui.icf_latency.String = num2str(read_in_info.icf_mep_beg_t);
% 		app.sici_ui.icf_latency.UserData.mep_beg_t = read_in_info.icf_mep_beg_t;
% 		app.sici_ui.icf_latency.UserData.mep_end_t = read_in_info.icf_mep_end_t;
% 		app.sici_ui.icf_latency.UserData.epochs_used = read_in_info.icf_epochs_used;
% 		app.sici_ui.icf_latency.UserData.num_sd = read_in_info.icf_num_sd;
		
		
		if isfield(read_in_info, 'analyzed_by')
			app.AnalyzedbyEditField.Value = upper(read_in_info.analyzed_by);
% 			app.h_edit_mep_done_by.String  = upper(read_in_info.analyzed_by);
% 			app.h_using_data_txt.String = 'Using:';
		else
			app.AnalyzedbyEditField.Value = '???';
		end
		if isfield(read_in_info, 'analyzed_when')
			app.AnalyzedWhenEditField.Value = read_in_info.analyzed_when;
% 			app.h_edit_mep_done_when.String = read_in_info.analyzed_when;
		else
			app.AnalyzedWhenEditField.Value = '2022-00-00';
		end
% 		if isfield(read_in_info, 'comments')
% 			app.h_mep_analysis_comments.String = read_in_info.comments;
% 		end

% 	else
% 		disp('no previous sici_info.txt read in')
% 		app.AnalyzedbyEditField.Value = '???';
% 		app.AnalyzedWhenEditField.Value = '2022-00-00';
% 	end
end % sici


return
end