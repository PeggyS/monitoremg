function drawGoal_2mb(app)

	if isempty(app.hGoalLines)
        % resting emg goal lines
		app.hGoalLines(1) = line(app.UIAxes_1, [0.25 1.75], ...
			[app.EMG_2_rest_thresholdEditField.Value app.EMG_2_rest_thresholdEditField.Value], ...
			'LineWidth', 3, 'Color', [0.66 0.66 0.66]);
		app.hGoalLines(2) = line(app.UIAxes_2, [0.25 1.75], ...
			[app.EMG_1_rest_thresholdEditField.Value app.EMG_1_rest_thresholdEditField.Value], ...
			'LineWidth', 3, 'Color', [0.66 0.66 0.66]);
        % training left muscle 
        app.hGoalLines(3) = line(app.UIAxes_1, [0.25 1.75], ...
			[app.EMG_1_train_goal.Value app.EMG_1_train_goal.Value], ...
			'LineWidth', 5, 'Color', [0.45 0.15 0.15]);
	else
		set(app.hGoalLines(1), 'YData', [app.EMG_1_rest_thresholdEditField.Value app.EMG_1_rest_thresholdEditField.Value]);
		set(app.hGoalLines(2), 'YData', [app.EMG_2_rest_thresholdEditField.Value app.EMG_2_rest_thresholdEditField.Value]);
        set(app.hGoalLines(3), 'YData', [app.EMG_1_train_goal.Value app.EMG_1_train_goal.Value]);
		set(app.hGoalLines, 'Visible', 'on')
	end
return
	