function update_avg_emg(source, event, app)

% get emg data & display average
if isprop(app, 'fullfilename') %% emg_rc app is running
	if isempty(app.fullfilename)
		return
	end
	data = load(app.fullfilename);
	% remove rows not being used (col = 0)
	row_msk = data(:,1) > 0;
	data = data(row_msk,:);

elseif isprop(app, 'EMGDataTxtEditField') %% review_emg_rc is running
	data = app.emg_data;
	if app.emg_data_num_vals_ignore < 2 %% old data, need to add Use column
		data = [zeros(size(data,1), 1) data];
	end
	% change 1st col of data (use value) to the checkboxes in the uitable
	row_msk = [app.h_uitable.Data{:,2}]';
	data(:,1) = row_msk;
	data = data(row_msk,:);
else
	return
end


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