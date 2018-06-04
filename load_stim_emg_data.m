function load_stim_emg_data(source,event, h_ax)

[filename, pathname] = uigetfile('*.txt', 'Pick a text file with MagStim_Setting and MEPAmpl_uVPp');
if isequal(filename,0) || isequal(pathname,0)
   disp('User pressed cancel')
else
   fname = fullfile(pathname, filename);
end
		
data = readtable(fname, 'delimiter', '\t');

for cnt = 1:height(data)
	if data.Use(cnt)
		add_point2rc(h_ax, data.Epoch(cnt), data.MagStim_Setting(cnt), data.MEPAmpl_uVPp(cnt))
	end
end
% data table is saved in axes userdata
h_ax.UserData = data;

return