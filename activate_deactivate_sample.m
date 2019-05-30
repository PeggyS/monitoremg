function activate_deactivate_sample(source, event, app)

sample_num = str2double(app.sample_num_text.String);

if sample_num < 1
	return
end

fid = fopen(app.fullfilename, 'rt+');
% skip past lines until our sample
throwaway = textscan(fid, '%[^\n]', 0, 'HeaderLines', sample_num-1);

f_loc = ftell(fid); % save location in file
% get next int (1=active, 0 = not active)
% act_inact = fscanf(fid, '%d');
% move back to that position in the file
fseek(fid, f_loc, 'bof');

% i tried removing ftell & fseek and it didn't overwrite the data!

% write over that value with the new 
fprintf(fid, '%d', source.Value);
fclose(fid);