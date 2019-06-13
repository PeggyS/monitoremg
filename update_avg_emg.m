function update_avg_emg(source, event, app)

% get emg data & display average
if isempty(app.fullfilename)
	return
end

data = load(app.fullfilename);
% remove rows not being used (col = 0)
row_msk = data(:,1) > 0;
data = data(row_msk,:);

delete(app.avg_emg_axes.Children) %% remove existing lines

% draw new lines
axes(app.avg_emg_axes)

for cnt = 1:size(data,1)
	line(app.avg_emg_axes.UserData.t, data(cnt,3:end), 'Color', [0.8 0.8 0.8])
end

% the mean line
line(app.avg_emg_axes.UserData.t, mean(data(:,3:end)), 'LineWidth', 5)

% update display of number of trials being averaged
app.avg_num_lines.String = ['Num trials = ' num2str(sum(row_msk))];