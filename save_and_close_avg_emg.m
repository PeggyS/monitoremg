function save_and_close_avg_emg(source, event, app)

if strcmp(source.Tag, 'pushbutton')  % don't delete if the save pushbutton called this function
	return
end

% delete the figure
delete(source)

% change checkbox
if any(strcmp(properties(app), 'CheckBoxAverageEmg'))
	app.CheckBoxAverageEmg.Value = 0;
end


return