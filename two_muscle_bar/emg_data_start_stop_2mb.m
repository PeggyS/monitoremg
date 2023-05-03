function emg_data_start_stop_2mb(app)

if app.StartButton.Value 
%    parameter_file = app.param_fname;
%    if ~exist(parameter_file, 'file')
%       [filename, pathname] = uigetfile( ...
%          {'*.txt';'*.*'}, ...
%          'Choose Parameter File');
%       parameter_file = fullfile(pathname, filename);
%    end
%    if ~exist(parameter_file, 'file')
%       error( 'error finding parameter file, %s', parameter_file)
%    end
%    % read in the parameter file
%    keywords = {'addr' 'freq' 'period' 'chan' 'goal' 'pre' 'post'};
%    defaults = {'192.168.1.102', 2500, 0.5, 1, 0.2, 50, 100};
%    paramscell = readparamfile(parameter_file, keywords, defaults);
%    app.params.ipAddr    = paramscell{1};
%    app.params.sampFreq  = paramscell{2};
%    app.params.avgPeriod = paramscell{3};
%    app.params.dispChan  = paramscell{4};
%    app.params.goalPct   = paramscell{5};
%    app.params.preTriggerTime  = paramscell{6};
%    app.params.postTriggerTime = paramscell{7};
%    
   % create tcpip object
   app.tcp_port = tcpip(app.params.ipAddr, 51234);	%% local machine & 16-bit port (32-bit port: 51244)
   
   % configure object -- InputBufferSize
   get(app.tcp_port, 'InputBufferSize');
  %    set(app.tcp_port, 'InputBufferSize', 2000); %  buffer size for Brainsight
   set(app.tcp_port, 'InputBufferSize', 27000); % increase buffer size for eeg system
   
   % configure object -- byteOrder
   set(app.tcp_port, 'ByteOrder', 'littleEndian');
   
   % connect
   % === DEBUG - comment out to run without communicating with Recorder
   fopen(app.tcp_port);
   % verify connection status
   if ~strcmp(get(app.tcp_port, 'Status'), 'open')
      disp('tcpip socket not open')
      return
   end
   % === end DEBUG
   % tcpipinfo=instrhwinfo('tcpip')
   
   % initialize data vector for the emg bar display
   app.emgBarDataVec = zeros(2, round(app.params.sampFreq*app.params.avgPeriod));

   % data vector for finding MEP peak-to-peak value relative to the trigger
%    seg_time = (app.params.postTriggerTime + app.params.preTriggerTime) / 1000;
%    app.emgTriggerDataMat = zeros(num_chans, round(app.params.sampFreq*seg_time));

   
   
% 	% emg data
% 	filename = 'emg_data.data';
% % 	if ~exist(filename, 'file')
% 		[f, msg] = fopen(filename, 'wb');
% 		if f ~= -1
% 			fwrite(f, zeros(1,2), 'uint8');
% 			fwrite(f, zeros(1,length(app.emgTriggerDataVec)), 'double');
% 			fclose(f);
% 		else
% 			error('MATLAB:demo:send:cannotOpenFile', ...
% 				'Cannot open file "%s": %s.', filename, msg);
% 		end
% % 	end
% 	% Memory map the file.
% 	app.emg_data_mmap = memmapfile(filename, 'Writable', true, ... 
% 		'Format', ...
% 		{'uint8', [1 1], 'new_data'; 'uint8', [1 1], 'magstim_val';
% 		'double', [1 length(app.emgTriggerDataVec)], 'emg_data'});
	
   % parameters to high pass filter at 10 Hz
   [app.hpFilt.b, app.hpFilt.a] = butter(4, 10/(app.params.sampFreq/2), 'high');
   
   %app.quitFlg = false;
   app.StartButton.Text = 'Stop';
   run_emg_2mb(app)
else
   %app.quitFlg = true;
   app.StartButton.Text = 'Run';
   fclose(app.tcp_port);
end

return