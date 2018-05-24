function removeGoal(app)
	% if isfield(app, 'hGoalLines') &&
	if ~isempty(app.hGoalLines)
		set(app.hGoalLines, 'Visible', 'off')
		% delete(app.hGoalLines(:)); 
		% app.hGoalLines = [];
	end
	set(app.hLine, 'Color', [0.1 0.1 1])
end