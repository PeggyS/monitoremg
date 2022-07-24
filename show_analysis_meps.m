function show_analysis_meps(~, ~, app)
% only show 

if isprop(app, 'mep_info')
	% make sure data used is the same as the type of data being viewed now
	if isfield(app.mep_info, 'using_rc_or_sici_data')
		if isempty(app.mep_info.using_rc_or_sici_data)
			disp('MEP times analysis not done yet.')
			return
		end
		if app.CheckBoxRc.Value == 1 && ~contains(app.mep_info.using_rc_or_sici_data, 'rc')
			disp(['Currently viewing RC data. MEP times were computed using ' ...
				app.mep_info.using_rc_or_sici_data ' data.'])
			return
		end
		if app.CheckBoxSici.Value == 1 && ~contains(app.mep_info.using_rc_or_sici_data, 'sici')
			disp(['Currently viewing SICI data. MEP times were computed using ' ...
				app.mep_info.using_rc_or_sici_data ' data.'])
			return
		end

	if isfield(app.mep_info, 'epochs_used')
		if ~isempty(app.mep_info.epochs_used)

			% select the cells
			jUIScrollPane = findjobj(app.h_uitable);
			jUITable = jUIScrollPane.getViewport.getView;
			j_now_selected_rows = jUITable.getSelectedRows;

			% rows that are selected and should not be
			tmp1 = setdiff(j_now_selected_rows+1, app.mep_info.epochs_used);
			% rows that are not selected but should be
			tmp2 = setdiff(app.mep_info.epochs_used, j_now_selected_rows+1);

			rows2toggle = union(tmp1, tmp2);

			for r_cnt = 1:length(rows2toggle)
				row = rows2toggle(r_cnt);
				col = 1;
				% toggle the row
				jUITable.changeSelection(row-1,col-1, true, false);
			end

		end % ~isempty
	end % isfield
end % isprop
return
end % show_analysis_meps