function [confirm_saving, fname] = confirm_savename(fname)
% if the fname exists, confirm to save and overwrite the file or to append
% the date & time to the file name

confirm_saving = true;

if exist(fname, 'file')
	suffix_str = datestr(now, '_yyyymmdd_HHMMSS');
	q_str = ['\fontsize{14} ' strrep(fname, '_', '\_') ...
		' already exists.\newline' ...
		'Do you want to:\newline - Save a new version with the datetime suffix (Add Suffix)\newline' ...
		'- Overwrite the existing (Overwrite) \newline' ...
		'- Do not save anything (Cancel) \newline'];
	btn1 = 'Add Suffix';
	btn2 = 'Overwrite';
	btn3 = 'Cancel';
	opts.Interpreter = 'tex';
	opts.Default = 'Yes';
	ans_button = questdlg(q_str, 'Save File', btn1, btn2, btn3, opts);
	
	switch ans_button
		case btn1
			[pn, fn, ext] = fileparts(fname);
			fname = fullfile(pn, [fn suffix_str ext]);
		case btn2
			% fname is unchanged
		case btn3
			confirm_saving = false; % don't save datapoint_fname
	end
end	
return