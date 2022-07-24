function f_name = get_rc_fit_info_file_name(app)

% starting from datapoints file name, reconstruct what the rc fit info file
% name should be
starting_f_name = app.DatapointsCSVEditField.Value;

% find out if app is displaying MEP ampl or auc
[~, mep_method] = get_data_var_mep_method(app);

fit_info_fname = strrep(starting_f_name, 'rc_datapoints.csv', mep_method);
if str2double(app.rc_fit_ui.edNormFactor.String) > 1
	norm_str = '_fit_info_norm.txt';
else
	norm_str = '_fit_info_not_norm.txt';
end
f_name = [fit_info_fname norm_str];


return
end