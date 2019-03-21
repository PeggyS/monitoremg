function update_sici_mean_sc_ci_lines(app, stim_type, info_var)

h_ax = app.sici_axes;

% once there are 5 points, draw the mean & std dev of the data points
tbl_stim_type = h_ax.UserData(strcmp(h_ax.UserData.Sici_or_icf_or_ts, stim_type), :);
tbl_use = tbl_stim_type(tbl_stim_type.Use==1,:);
n_var = [info_var '_n'];
app.sici_ui.(n_var).String = num2str(height(tbl_use));
app.sici_info.(n_var) = num2str(height(tbl_use));
if height(tbl_use) >= 3
	mean_var = [info_var '_mean' ];	
	mean_val = mean(tbl_use.MEPAmpl_uVPp);
	app.sici_ui.(mean_var).String = num2str(mean_val,'%4.0f');
	ci_var = [info_var '_ci'];
	sd_val = std(tbl_use.MEPAmpl_uVPp);
	ci_val = confidence_intervals(tbl_use.MEPAmpl_uVPp, 98);
	ci_str = sprintf('[%4.0f, %4.0f]', mean_val+ci_val(1), mean_val+ci_val(2));
	app.sici_ui.(ci_var).String = ci_str;
	m_line_var = [info_var '_mline'];
	
	app.sici_ui.(m_line_var).YData = [mean_val mean_val];
	up_line_var = [info_var '_sdupline'];
	app.sici_ui.(up_line_var).YData = [mean_val+sd_val mean_val+sd_val];
	dwn_line_var = [info_var '_sddownline'];
	app.sici_ui.(dwn_line_var).YData = [mean_val-sd_val mean_val-sd_val];
	
	up_line_var = [info_var '_ciupline'];
	app.sici_ui.(up_line_var).YData = [mean_val+ci_val(2) mean_val+ci_val(2)];
	dwn_line_var = [info_var '_cidownline'];
	app.sici_ui.(dwn_line_var).YData = [mean_val+ci_val(1) mean_val+ci_val(1)];

	app.sici_info.(mean_var) = mean_val;
	app.sici_info.(ci_var) = mean_val + ci_val;

end

