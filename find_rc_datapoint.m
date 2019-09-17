function h_line = find_rc_datapoint(h_ax, table_row_num)
h_line = [];

h_dp_lines = findobj(h_ax, 'Type', 'line', 'Tag', '');

for l_cnt = 1:length(h_dp_lines)
	if isfield(h_dp_lines(l_cnt).UserData, 'table_row_num')
		if h_dp_lines(l_cnt).UserData.table_row_num == table_row_num
			h_line = h_dp_lines(l_cnt);
			return
		end
	end
end