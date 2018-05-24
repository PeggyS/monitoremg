function drawGoal(app)
	%if isfield(handles, 'hGoalLines'), 
	%	delete(handles.hGoalLines(:)); 
	%	delete(handles.hGoalLines);
	%end
    % removeGoal(app);
    yMax = max(ceil(app.params.goalPct * app.peakVal * 2), 1);
    set(app.YmaxEditField, 'Value', yMax);
	set(app.UIAxes, 'YLim', [0 yMax]);

   	set(app.hPeakLine, 'Visible', 'off')
   	
	goalVal = app.params.goalPct * app.peakVal;
	goalMin = goalVal - 0.05*app.peakVal;
	goalMax = goalVal + 0.05*app.peakVal;

	if isempty(app.hGoalLines)
		app.hGoalLines(1) = line(app.UIAxes, [0.25 1.75], [goalVal goalVal]);
    	set(app.hGoalLines(1), 'LineWidth', 5)
	
	
		app.hGoalLines(2) = line(app.UIAxes, [0.25 1.75], [goalMin goalMin]);
		app.hGoalLines(3) = line(app.UIAxes, [0.25 1.75], [goalMax goalMax]);
		set(app.hGoalLines(2:3), 'LineStyle', '--', 'LineWidth', 3); 
	else
		set(app.hGoalLines(1), 'YData', [goalVal goalVal]);
		set(app.hGoalLines(2), 'YData', [goalMin goalMin]);
		set(app.hGoalLines(3), 'YData', [goalMax goalMax]);
		set(app.hGoalLines, 'Visible', 'on')
	end
return
	