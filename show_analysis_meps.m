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
% 		if app.CheckBoxSici.Value == 1 && ~contains(app.mep_info.using_rc_or_sici_data, 'sici')
% 			disp(['Currently viewing SICI data. MEP times were computed using ' ...
% 				app.mep_info.using_rc_or_sici_data ' data.'])
% 			return
% 		end

		rows_used = [];
		% get table rows used if rc analysis
		if app.CheckBoxRc.Value == 1 && isfield(app.mep_info, 'epochs_used_for_latency')
			if ~isempty(app.mep_info.epochs_used_for_latency)
				rows_used = app.mep_info.epochs_used_for_latency;
			end
		end
		% get tablw rows used if sici analysis
		if app.CheckBoxSici.Value == 1 && isgraphics(app.sici_fig)
			% selected table rows
			% find currently selected cells
			jUIScrollPane = findjobj(app.h_uitable);
			jUITable = jUIScrollPane.getViewport.getView;
			j_now_selected_rows = jUITable.getSelectedRows;
			
			% stim type col from the table
			st_col = find(contains(app.h_uitable.ColumnName, 'Type'));
			st_list = app.h_uitable.Data(j_now_selected_rows+1, st_col);
			if length(st_list) > 1
				st = unique(st_list);
				if length(st) > 1
					disp('more than 1 stim type chosen')
					beep
					return
				end
				st_var = lower(st{:});
			else
				st_var = lower(st_list{:});
			end
			if strcmp(st_var, 'test stim')
				st_var = 'ts';
			end

			st_var_latency = [st_var '_latency'];

			if isfield(app.sici_ui, st_var_latency) && isfield(app.sici_ui.(st_var_latency).UserData, 'epochs_used')
				rows_used = app.sici_ui.(st_var_latency).UserData.epochs_used;
			end
		end

		if isempty(rows_used)
			return
		end
		
		% find currently selected cells
		jUIScrollPane = findjobj(app.h_uitable);
		jUITable = jUIScrollPane.getViewport.getView;
		j_now_selected_rows = jUITable.getSelectedRows;

		% toggle currently selected rows
		for r_cnt = 1:length(j_now_selected_rows)
			row = j_now_selected_rows(r_cnt);
			col = 1;
			% toggle the row
			jUITable.changeSelection(row,col-1, true, false);
		end
		
		% select the rows used
		for r_cnt = 1:length(rows_used)
			row = rows_used(r_cnt);
			col = 1;
			% toggle the row
			jUITable.changeSelection(row-1,col-1, true, false);
		end

	end % isfield
end % isprop
return
end % show_analysis_meps