function get_emgdata_sample(source, event, app)

sample_num = str2double(app.sample_num_text.String);

if sample_num < 1
	return
end

switch source.Tag
	case 'next_sample_pushbutton'
		sample_num = sample_num+1;
	case 'previous_sample_pushbutton'
		sample_num = sample_num-1;
		if sample_num < 1 
			sample_num = 1;
		end
end

fid = fopen(app.fullfilename, 'rt');
% read in 1 line for the sample skipping past all other lines
line_cell = textscan(fid, '%[^\n]', 1, 'HeaderLines', sample_num-1);
fclose(fid);

% if nothing was read in by either trying to read beyond the end of the file 
if isempty(line_cell{1})
	return
end

% keyboard
b = textscan(char(line_cell{1}), '', 1, 'Delimiter', ',', 'CollectOutput', true);
data = b{1};
emg_data = data(6:end); % 2025-11-19: FIXed - 3 here is not correct anymore (2022-07-14), changed to 6 (5 numbers stored at beginning of emg data are to be ignored)
stim_info.magstim_val = emg_data(2);
stim_info.bistim_val = emg_data(3);
stim_info.isi_ms	 = emg_data(4);
stim_info.effective_so = emg_data(5);

draw_emg_data(app, emg_data, [], [], [], stim_info); % 2025-11-19: FIXed - need to send along the stim info
app.sample_num_text.String = num2str(sample_num);
app.active_sample_checkbox.Value = data(1);