function data_point_enable_disable(source, event, h_line, h_ax)
switch source.Label
	case 'Disable'
		h_line.Marker = 'x';
		h_line.MarkerSize = h_line.MarkerSize/2;
		source.Label = 'Enable';
		h_ax.UserData.Use(h_line.UserData.table_row_num) = 0;
	case 'Enable'
		h_line.Marker = '.';
		h_line.MarkerSize = h_line.MarkerSize*2;
		source.Label = 'Disable';
		h_ax.UserData.Use(h_line.UserData.table_row_num) = 1;
	case 'Disable All'
		% find all lines at this x value
		h_all_lines = findobj(h_ax, 'XData', h_line.XData);
		for l_cnt = 1:length(h_all_lines)
			menu_list =  h_all_lines(l_cnt).UIContextMenu.Children;
			for m_cnt = 1:length(menu_list)
				if strcmp(menu_list(m_cnt).Text, 'Disable')
					data_point_enable_disable(menu_list(m_cnt), [], h_all_lines(l_cnt), h_ax)
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
					data_point_enable_disable(menu_list(m_cnt), [], h_all_lines(l_cnt), h_ax)
				end
			end
		end
		source.Label = 'Disable All';
end
return