function save_rc_table(data, fname)
% save the data table to a csv file
% starting 2022-07-17 add the stimulator hardware setup as an additional
% header line

stimulator_setup = 'bistim'; % default when recording new data

emg_fig = findwind('EMG Data', 'Name');
if ishandle(emg_fig)
	h_stim_setup = findobj(emg_fig, 'Tag', 'stim_setup_text');
	if ~isempty(h_stim_setup)
		stimulator_setup = lower(h_stim_setup.String);
	end
end

if height(data) > 0
	% write the stimulatore setup
	fid = fopen(fname, 'wt');
	if fid > 0
		fprintf(fid, '%s\n', stimulator_setup);
		fclose(fid);
	else
		error(['save_rc_table: could not open file ' fname])
	end
	% append the data
	if verLessThan('matlab', '9.10')
		writetable(data, fname, 'WriteVariableNames',true)
	else
		writetable(data, fname, 'WriteMode','Append','WriteVariableNames',true)
	end
else
	disp('no data points to save')
end

return