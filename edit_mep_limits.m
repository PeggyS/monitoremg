function edit_mep_limits(source, event, app)
val = str2double(source.String);

switch source.Tag
	case 'edit_mep_begin'
		h_line = app.h_t_min_line;
	case 'edit_mep_end'
		h_line = app.h_t_max_line;
end

h_line.XData = [val val];
mep_line_drag_endfcn(h_line)