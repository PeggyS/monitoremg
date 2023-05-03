function drawGoal_2mb(app)

	if isempty(app.hGoalLines)
		app.hGoalLines(1) = line(app.UIAxes_1, [0.25 1.75], ...
			[app.EMG_2_rest_thresholdEditField.Value app.EMG_2_rest_thresholdEditField.Value], ...
			'LineWidth', 5, 'Color', [0.9 0 0]);
		app.hGoalLines(2) = line(app.UIAxes_2, [0.25 1.75], ...
			[app.EMG_1_rest_thresholdEditField.Value app.EMG_1_rest_thresholdEditField.Value], ...
			'LineWidth', 5, 'Color', [0.9 0 0]);
	else
		set(app.hGoalLines(1), 'YData', [app.EMG_1_rest_thresholdEditField.Value app.EMG_1_rest_thresholdEditField.Value]);
		set(app.hGoalLines(2), 'YData', [app.EMG_2_rest_thresholdEditField.Value app.EMG_2_rest_thresholdEditField.Value]);
		set(app.hGoalLines, 'Visible', 'on')
	end
return
	