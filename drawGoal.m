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
   	
	app.goalVal = app.params.goalPct * app.peakVal;
	app.goalMin = app.goalVal - 0.05*app.peakVal;
	app.goalMax = app.goalVal + 0.05*app.peakVal;

	if isempty(app.hGoalLines)
		app.hGoalLines(1) = line(app.UIAxes, [0.25 1.75], [app.goalVal app.goalVal]);
    	set(app.hGoalLines(1), 'LineWidth', 5)
	
	
		app.hGoalLines(2) = line(app.UIAxes, [0.25 1.75], [app.goalMin app.goalMin]);
		app.hGoalLines(3) = line(app.UIAxes, [0.25 1.75], [app.goalMax app.goalMax]);
		set(app.hGoalLines(2:3), 'LineStyle', '--', 'LineWidth', 3); 
	else
		set(app.hGoalLines(1), 'YData', [app.goalVal app.goalVal]);
		set(app.hGoalLines(2), 'YData', [app.goalMin app.goalMin]);
		set(app.hGoalLines(3), 'YData', [app.goalMax app.goalMax]);
		set(app.hGoalLines, 'Visible', 'on')
	end
return
	