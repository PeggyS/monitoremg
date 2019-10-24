function rc_change_norm_factor(source,event, app)

% norm factor
norm_factor = str2double(app.rc_fit_ui.edNormFactor.String);

h_ax = app.rc_axes;
cla(h_ax)

if norm_factor == 1
	h_ax.YLabel.String = 'EMG (µV)';
else
	h_ax.YLabel.String = 'Normalized EMG';
end

data = app.rc_axes.UserData;

for cnt = 1:height(data)
	if data.Use(cnt)
		add_point2rc(h_ax, data.Epoch(cnt), data.MagStim_Setting(cnt), data.MEPAmpl_uVPp(cnt)/norm_factor)
	end
end