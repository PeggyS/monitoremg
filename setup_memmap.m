function setup_memmap(app, which_map)

% 
seg_time = (app.params.postTriggerTime + app.params.preTriggerTime) / 1000;
seg_num_points = round(app.params.sampFreq*seg_time);
% % time vector in msec
% t = (0:1/app.params.sampFreq:(seg_time-1/app.params.sampFreq))*1000 - app.params.preTriggerTime;


filename = [which_map '.data'];
if ~exist(filename, 'file')
	[f, msg] = fopen(filename, 'wb');
	if f ~= -1
		switch which_map
			case 'emg_data'
				fwrite(f, zeros(1,35), 'uint8'); 
				% 1 for new data indicator flag, 
				% 1 for magstim val
				% 3 for goal val, min & max
				% 30 for muscle nam

				fwrite(f, zeros(1,seg_num_points), 'double'); % emg data
			otherwise
				% body
		end
		
		fclose(f);
	else
		error('MATLAB:demo:send:cannotOpenFile', ...
			'Cannot open file "%s": %s.', filename, msg);
	end
end

switch which_map
	case 'emg_data'
		app.emg_data_mmap = memmapfile(filename, 'Writable', true, ...
   			'Format', {'uint8', [1 1], 'new_data'; 
   			'uint8', [1 1], 'magstim_val';
   			'uint8', [1 1], 'goal_val';
   			'uint8', [1 1], 'goal_min';
   			'uint8', [1 1], 'goal_max';
   			'uint8', [1 30], 'muscle_name';
    		'double', [1 seg_num_points], 'emg_data'});
	% case 'rc_data'
	% 	if ~exist(filename, 'file')
	% 		 [f, msg] = fopen(filename, 'wb');
	% 		 if f ~= -1
	% 		    fwrite(f, zeros(1,1), 'uint8');
	% 		    fwrite(f, zeros(1,1), 'uint8');
	% 		    fwrite(f, zeros(1,1), 'double');
	% 		    fclose(f);
	% 		 else
	% 		 	error('MATLAB:setup_memmap:cannotOpenFile', ...
	% 		          'Cannot open file "%s": %s.', ...
	% 		          filename, msg);
	% 		 end
	% 	end
	% 	app.rc_data_mmap = memmapfile(filename, 'Writable', true, ...
	% 	   'Format', {'uint8', [1 1], 'new_data'; 
	% 	              'uint8', [1 1], 'magstim_val'; 
	% 	              'double', [1 1], 'mep_val'});
	otherwise
		% body
end
