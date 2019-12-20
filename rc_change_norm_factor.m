function rc_change_norm_factor(source,event, app)

% norm factor
norm_factor = str2double(app.rc_fit_ui.edNormFactor.String);

h_ax = app.rc_axes;
% cla(h_ax)

% find out if app is displaying MEP ampl or auc
tag = 'rb_mep_pp'; % default is p2p amplitude
if isprop(app, 'h_radio_mep')
	for kk = 1:length(app.h_radio_mep.Children)
		if app.h_radio_mep.Children(kk).Value
			tag = app.h_radio_mep.Children(kk).Tag; % tag of selected radio button (either rb_mep_pp, or rb_mep_auc)
		end
	end
end
switch tag
	case 'rb_mep_pp'
		if norm_factor == 1
			h_ax.YLabel.String = 'MEP Vp-p (µV)';
		else
			h_ax.YLabel.String = 'Normalized EMG Amplitude';
		end
		data_var = 'MEPAmpl_uVPp';
	case 'rb_mep_auc'
		if norm_factor == 1
			h_ax.YLabel.String = 'MEP AUC (µV*ms)';
		else
			h_ax.YLabel.String = 'Normalized EMG AUC';
		end
		data_var = 'MEPAUC_uV_ms';
end

% if norm_factor == 1
% 	h_ax.YLabel.String = 'EMG (µV)';
% else
% 	h_ax.YLabel.String = 'Normalized EMG';
% end

data = app.rc_axes.UserData;

% for cnt = 1:height(data)
% 	if data.Use(cnt)
% 		add_point2rc(h_ax, data.Epoch(cnt), data.MagStim_Setting(cnt), data.(data_var)(cnt)/norm_factor)
% 	end
% end



for row_cnt = 1:height(app.rc_axes.UserData)
	h_line = find_rc_datapoint(app.rc_axes, row_cnt);
	h_line.YData = app.rc_axes.UserData.(data_var)(row_cnt)/norm_factor;
end
