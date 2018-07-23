function load_stim_emg_data(source,event, app)

[filename, pathname] = uigetfile('*.txt; *.csv', 'Pick a text file with MagStim_Setting and MEPAmpl_uVPp');
if isequal(filename,0) || isequal(pathname,0)
   disp('User pressed cancel')
else
   fname = fullfile(pathname, filename);
end

switch filename(end-2:end)
	case 'txt'
		data = readtable(fname, 'delimiter', '\t');
	case 'csv'
		data = readtable(fname);
end

% clear any existing points
cla(app.rc_axes)

% norm factor
norm_factor = str2double(app.rc_fit_ui.edNormFactor.String);

for cnt = 1:height(data)
	if data.Use(cnt)
		add_point2rc(app.rc_axes, data.Epoch(cnt), data.MagStim_Setting(cnt), data.MEPAmpl_uVPp(cnt)/norm_factor)
	end
end
% data table is saved in axes userdata
app.rc_axes.UserData = data;

return