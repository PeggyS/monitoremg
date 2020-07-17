function pushbutton_use(src, evt, app, all_or_none)

num_rows = size(app.h_uitable.Data,1);

switch all_or_none
	case 'all'
		use = true(num_rows, 1);
	case 'none'
		use = false(num_rows, 1);
	otherwise
		return
end

app.h_uitable.Data(:,2) = num2cell(use);