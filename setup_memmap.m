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
				% with provision for up to 8 channels
				fwrite(f, zeros(1,38*8), 'uint8'); 
				% 1 for new data indicator flag, 
				% 3 for magstim, bistim, and isi 
				% 3 for goal val, min & max
				% 1 for pre-stim emg
				% 30 for muscle nam
				
				% emg data
				fwrite(f, zeros(1,seg_num_points*8), 'double');
			case 'data_channels'
				fwrite(f, zeros(1,1*8), 'uint8'); % number of data channels being sent from brainVision
				% flag for if this is the channel in the activity monitor figure
				fwrite(f, zeros(1,1*8), 'uint8');
				% make space for up to 8 channel names - 30 char each
				fwrite(f, zeros(1,8*30), 'uint8'); % 
				% space to store for each channel to save or not
				fwrite(f, zeros(1,1*8), 'uint8');
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
				'uint8', [1 1], 'bistim_val';
				'uint8', [1 1], 'isi_ms';
				'uint8', [1 1], 'goal_val';
				'uint8', [1 1], 'goal_min';
				'uint8', [1 1], 'goal_max';
				'uint8', [1 1], 'monitor_emg_val';
				'uint8', [1 30], 'muscle_name';
				'double', [1 seg_num_points], 'emg_data'},...
			'Repeat', 8);
	case 'data_channels'
		app.data_channels_mmap = memmapfile(filename, 'Writable', true, ...
			'Format', {'uint8', [1 1], 'num_channels';
				'uint8', [1 1], 'live_display';
				'uint8', [1 1], 'save';
				'uint8', [1 30], 'muscle_name'}, ...
			'Repeat', 8);
			
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
