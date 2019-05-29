function edit_xlims(source, event, app)
% update the xlimits of the emg data display axes

switch source.Tag
	case 'edit_xmin'
		app.h_disp_emg_axes.XLim(1) = str2double(source.String);
	case 'edit_xmax'
		app.h_disp_emg_axes.XLim(2) = str2double(source.String);
end

