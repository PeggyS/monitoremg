function data_point_menu_callback(source, event, h_line, h_ax)
switch source.Label
	case 'Disable'
		h_line.Marker = 'x';
		h_line.MarkerSize = h_line.MarkerSize/2;
		source.Label = 'Enable';
		h_ax.UserData.Use(h_line.UserData.table_row_num) = 0;
		% if in the review_emg app, update the uitable
		h_uitable = findobj('Tag', 'review_emg_uitable');
		if ~isempty(h_uitable)
			h_uitable.Data(h_line.UserData.table_row_num, 2) = {false};
		end
	case 'Enable'
		h_line.Marker = '.';
		h_line.MarkerSize = h_line.MarkerSize*2;
		source.Label = 'Disable';
		h_ax.UserData.Use(h_line.UserData.table_row_num) = 1;
		% if in the review_emg app, update the uitable
		h_uitable = findobj('Tag', 'review_emg_uitable');
		if ~isempty(h_uitable)
			h_uitable.Data(h_line.UserData.table_row_num, 2) = {true};
		end
	case 'Disable All'
		% find all lines at this x value
		h_all_lines = findobj(h_ax, 'XData', h_line.XData);
		for l_cnt = 1:length(h_all_lines)
			menu_list =  h_all_lines(l_cnt).UIContextMenu.Children;
			for m_cnt = 1:length(menu_list)
				if strcmp(menu_list(m_cnt).Text, 'Disable')
					data_point_menu_callback(menu_list(m_cnt), [], h_all_lines(l_cnt), h_ax)
				end
			end
		end
		source.Label = 'Enable All';
	case 'Enable All'
		% find all lines at this x value
		h_all_lines = findobj(h_ax, 'XData', h_line.XData);
		for l_cnt = 1:length(h_all_lines)
			menu_list =  h_all_lines(l_cnt).UIContextMenu.Children;
			for m_cnt = 1:length(menu_list)
				if strcmp(menu_list(m_cnt).Text, 'Enable')
					data_point_menu_callback(menu_list(m_cnt), [], h_all_lines(l_cnt), h_ax)
				end
			end
		end
		source.Label = 'Disable All';
	case 'Show in Table'
		h_emg_data_fig = findwind('EMG Data', 'Name');
		if ishandle(h_emg_data_fig)
			% runing in review_emg_rc.mlapp
			%  update the uitable
			hf=h_ax.Parent;
			hf.UserData.app.h_edit_epoch.String = num2str(h_line.UserData.table_row_num);
			edit_epoch(hf.UserData.app.h_edit_epoch, [], hf.UserData.app) % update the epoch number edit box
% 			% select the row in the uitable
% 			h_uitable = findobj(h_emg_data_fig, 'Tag', 'review_emg_uitable');
% 			jUIScrollPane = findjobj(h_uitable);
% 			jUITable = jUIScrollPane.getViewport.getView;
% 			j_selected_rows = jUITable.getSelectedRows;
% 			if ~isempty(j_selected_rows)
% 				fprintf('table cells already selected ..unselecting them\n')
% 				for r_cnt = 1:length(j_selected_rows)
% 					col = 1;
% 					jUITable.changeSelection(j_selected_rows(r_cnt),col-1, true, false); % toggle selection
% 				end
% 			end
% 			% toggle newly selected epoch/row number
% 			col = 1;
% 			jUITable.changeSelection(h_line.UserData.table_row_num-1,col-1, true, false);
		end
end

return
end % function