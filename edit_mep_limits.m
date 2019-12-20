function edit_mep_limits(source, event, app)
val = str2double(source.String);

switch source.Tag
	case 'edit_mep_begin'
		h_line = app.h_t_min_line;
	case 'edit_mep_end'
		h_line = app.h_t_max_line;
	case 'edit_mep_dur'
		h_line = app.h_t_max_line;
		h_beg_edit = findobj(source.Parent, 'Tag', 'edit_mep_begin');
		val = str2double(h_beg_edit.String) + str2double(source.String);
		h_end_edit = findobj(source.Parent, 'Tag', 'edit_mep_end');
		h_end_edit.String = num2str(val);
end

h_line.XData = [val val];
mep_line_drag_endfcn(h_line)