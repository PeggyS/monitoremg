function pushbutton_compute_mep_times(src, evt, app)  %#ok<INUSL>

pushbutton_adj_mep_beg(src, evt, app)
drawnow
pushbutton_adj_mep_end(src, evt, app)

if app.mep_times_changed_flag == true
	% save info used 
	save_computed_mep_info([], [], app)
	app.mep_times_changed_flag = false; % reset the flag
end

return
end % pushbutton_compute_mep_times