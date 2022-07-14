function run_emg(app)
triggerPos = NaN; % position/index in the datavec when the trigger msg was rec'd
% index when triggerPos is at correct position to record the proper pre & post amt of data
triggerInd = app.params.preTriggerTime / 1000 * app.params.sampFreq;

tic;
num_loops = 0;
% fid = fopen('emg_data.txt', 'w');
while app.StartButton.Value
   % get message from server
   t_start = tic;
   [blockSize, msgType, msgBlock] = getMsgBlock(app.tcp_port);
   dispChan = find(strcmp(app.EMGDropDown.Items, app.EMGDropDown.Value));
		
   % 	set(app.hLine, 'YData', [0 10]);
   switch msgType
      case 0		%% no socket open, not reading data
         % no nothing
      case 1		%% Start Message
         disp('Detected BrainVision. Start Monitoring')
         app.chanInfo = doStartMsg(msgBlock);
		 % verify correct sampling freq
		 assert(app.params.sampFreq == app.chanInfo.samp_freq, ...
			 'Samp freq mismatch: parameter file %s = %g; streaming data = %g', ...
			 app.param_fname, app.params.sampFreq, app.chanInfo.samp_freq)
		 
		 num_channels = length(app.chanInfo.names);
		 % save number of muscle names in data_channels_mmap
		 app.data_channels_mmap.Data(1).num_channels = uint8(num_channels);
		 for ch_cnt = 1:num_channels
			 % rename the emg channels from number to the muscle name
			 app.EMGDropDown.Items{ch_cnt} = app.chanInfo.names{ch_cnt};
			 % save muscle names in data_channels_mmap
			 app.data_channels_mmap.Data(ch_cnt).num_channels = uint8(num_channels);
			 app.data_channels_mmap.Data(ch_cnt).muscle_name = uint8(pad(app.chanInfo.names{ch_cnt}, 30));
			 app.data_channels_mmap.Data(ch_cnt).live_display = uint8(0);
		 end
		 % set dispChan in data_channels mmap
		 app.data_channels_mmap.Data(dispChan).live_display = uint8(1);
		 % init matrix to store emg data relative to the trigger
		 seg_time = (app.params.postTriggerTime + app.params.preTriggerTime) / 1000;
		 app.emgTriggerDataMat = zeros(num_channels, round(app.params.sampFreq*seg_time));

	
		 
      case 2		%% Data Message
%          fprintf('\n');
% 		 t_block_read = toc(t_start);
%          fprintf('Read in a block of data in %g sec\n', t_block_read)
         [data, numPoints, markInfo] = doDataMsg(msgBlock, app.chanInfo);
         % put new data into the data vectors
		 try
% 			 newData = double(data(dispChan,:)')*app.chanInfo.resolution(dispChan);
			 newData = double(data).*app.chanInfo.resolution;
		 catch
         beep
			 warning('Problem reading in data. Try to run again.')
			 app.StartButton.Value = 0;
          return
		 end
         newHpFiltData = filtfilt(app.hpFilt.b, app.hpFilt.a, newData(dispChan,:));
		 app.emgBarDataVec = circshift(app.emgBarDataVec, double(numPoints));
         app.emgBarDataVec(1:numPoints) = newHpFiltData;
         
         % update the activity bar
         updateDisplay(app, app.emgBarDataVec, markInfo);

         % filling in the trigger data vector
         if ~isnan(triggerPos)
         	% make sure not to shift the triggerPos farther back than the triggerInd
         	if triggerPos - numPoints <= triggerInd
         		shift_val = triggerPos - triggerInd;
         	else
         		shift_val = numPoints;
         	end
	         
	         % shift the data
	         app.emgTriggerDataMat = circshift(app.emgTriggerDataMat, -double(shift_val), 2);
	         %app.emgTriggerDataVec(end-shift_val+1:end) = newHpFiltData(1:shift_val);
			 app.emgTriggerDataMat(:,end-shift_val+1:end) = newData(:,1:shift_val);
	         triggerPos = triggerPos - shift_val;
% 			 disp(['triggerPos = ' num2str(triggerPos)])
			 
	         if triggerPos == triggerInd
				 % data to emg display app
				 for c_cnt = 1:num_channels
					app.emg_data_mmap.Data(c_cnt).emg_data = filtfilt(app.hpFilt.b, app.hpFilt.a, app.emgTriggerDataMat(c_cnt,:));
				 end
				app.emg_data_mmap.Data(1).new_data = uint8(1);
	         	% the data to save & find MEP
	         	% fprintf(fid, '%d,', magstim_val);
	         	% fprintf(fid, '%f,', app.emgTriggerDataVec);
	         	% fprintf(fid, '\n');
	         	% reset triggerPos
	         	triggerPos = NaN;
	         end

         	% sprintf('triggerPos = %d, numPoints = %d',  triggerPos, numPoints)
         else % don't have a triggerPos, shift & save new data
         	app.emgTriggerDataMat = circshift(app.emgTriggerDataMat, -double(numPoints), 2);
	         % app.emgTriggerDataVec(end-numPoints+1:end) = newHpFiltData;
			 app.emgTriggerDataMat(:,end-numPoints+1:end) = newData;
         end
         % detect if a trigger message was sent - examine markers
			if ~isempty(markInfo)
				% disp(markInfo.desc')
				% disp(markInfo.label)
				val = 1;
				if strncmp(markInfo(1).label', 'R128', 4)
					% markInfo.pos is zero-based relative position in the block 
					if isnan(triggerPos)
% 						disp(size(app.emgTriggerDataMat,2))
% 						disp(numPoints)
% 						disp(markInfo.pos)
						if length(markInfo) > 1
							for m_cnt = 1:length(markInfo)
								disp(['marker ' num2str(m_cnt)])
								disp(markInfo(m_cnt))
							end
						end
						triggerPos = size(app.emgTriggerDataMat,2)-numPoints + markInfo(1).pos; 
					end
					% fprintf('triggerPos = %d\n',  triggerPos);
					% get magstim value now
% 					msfid = fopen('magstim_val.txt', 'r');
% 					magstim_val = fscanf(msfid, '%d');
% 					fclose(msfid);
					% magstim info from magspy
					magstim_val = app.magstim_mmap.Data(1);
					bistim_val = app.magstim_mmap.Data(2);
					isi_ms = app.magstim_mmap.Data(3);
					% if in Bistim mode (both stimulators at the same
					% time), change the bistim_val to be the same as the
					% magstim_val
					if isi_ms == 0
						bistim_val = magstim_val;
					end
					% for the live_display channel and all save channels,
					% put info in the emg_data_memmap
					for c_cnt = 1:app.data_channels_mmap.Data(1).num_channels
						if app.data_channels_mmap.Data(c_cnt).live_display
							app.emg_data_mmap.Data(c_cnt).magstim_val = magstim_val;
							app.emg_data_mmap.Data(c_cnt).bistim_val = bistim_val;
							app.emg_data_mmap.Data(c_cnt).isi_ms = isi_ms;
% 							muscle_name = app.chanInfo.names{dispChan};
% 							if length(muscle_name) > 30, muscle_name = muscle_name(1:30); end
							app.emg_data_mmap.Data(c_cnt).muscle_name = uint8(pad(app.chanInfo.names{c_cnt}, 30));
							if ~isempty(app.goalVal)
							   app.emg_data_mmap.Data(c_cnt).goal_val = uint8(round(app.goalVal));
								app.emg_data_mmap.Data(c_cnt).goal_min = uint8(round(app.goalMin));
								app.emg_data_mmap.Data(c_cnt).goal_max = uint8(round(app.goalMax));
							end
							app.emg_data_mmap.Data(c_cnt).monitor_emg_val = uint8(round(app.monitorEMGval));
						end
					end
				end
			end
         

      case 3		%% Stop Message
         disp('BrainVision: Stop Monitoring')
         
   end
%    drawnow;
	pause(0)
%    num_loops = num_loops + 1;
%    t_while_loop = toc(t_start);
%    fprintf('Completed a while loop in %g sec\n', t_while_loop)
end
% fclose(fid);
set(app.hLine, 'YData', [0 1]);
% fprintf('read %d blocks, avg time = %g\n', num_loops, toc/num_loops)\
% fprintf('did %d while loops, avg time = %g\n', num_loops, toc/num_loops)
return

% ===============================================================================
function [blockSize, msgType, msgBlock] = getMsgBlock(t)
% message header:
%	guid		16 bytes (unique identifier) 8E45584396C9864CAF4A98BBF6C91450
%	blockSize	'ulong' size of msg block in bytes including this header
%	msgType		'ulong' message type {1-start; 2-data; 3-stop}

blockSize = []; msgType = 0; msgBlock = [];
if ~strcmp(get(t, 'Status'), 'open')
   return
end

% fread reads data using the 'uchar' unsigned character precision, 8 bits.
guid = fread(t, 16, 'uchar');	%% 16 bytes
% verify
% use dec2hex

blockSize = fread(t, 1, 'ulong');	%% 4 bytes
msgType = fread(t, 1, 'ulong');		%% 4 bytes

% read in : block as bytes (signed 8 bit integers)
msgBlock = int8([]);
blockSize = blockSize - 24;		%% rest of block (header = 24 bytes)
if blockSize < 0, error('header was < 24 bytes???'); end
if blockSize > 0
   msgBlock = int8(fread(t, blockSize, 'int8'));
   %    disp(msgBlock(1:4))
   %    size(msgBlock)
end

% get(t, 'ValuesReceived');
return

% ===============================================================================
function chanInfo = doStartMsg(msg)
%	msg - uchar vector of:
%
%	ULONG				nChannels;			// Number of channels
%	double				dSamplingInterval;	// Sampling interval in microseconds
%	double				dResolutions[nChannels];	// Array of channel resolutions coded in microvolts. i.e. RealValue = resolution * A/D value
%	char 		 		sChannelNames[nChannels];	// Channel names delimited by '\0'.

nChannels = typecast(msg(1:4), 'uint32');		%% 4 bytes
sampInterval = typecast(msg(5:12), 'double');	%% double = 8 bytes
chanInfo.samp_freq = 1/(sampInterval*1e-6);
len = nChannels * 8;							%% 8 bytes per channel
chanInfo.resolution = typecast(msg(13:13+len-1), 'double');		%% resolution for each channel

% channel names
% chanInfo.names = cell(nChannels,1);		%% initialize
p = 13+len;	%% position in byte block
% parse the names out of the msg block
% for i = 1:nChannels
% %    [name, ~] = textscan(char(msg(p:end)), '%s'); %% p is the end of the last scanned character
%    % textscan reads past the null char separating the channel names, so do not uses numCharRead
%    % 2018-06-06: textscan was returning a cell name: 1×1 cell array
%    %	 {'inv_ta inv_gastroc uninv_ta uninv_gastroc '}
%    % I don't know if this was always incorrect or that the behaviour of
%    % textscan changed.
%    chanInfo.names(i) = name{:};
%    p = p+length(chanInfo.names{i})+1;	%% move past the null byte to the beginning next string
%    % check that we haven't gone too far
%    if p > length(msg), return; end
%    
% end
tmp = textscan(char(msg(p:end)), '%s',4, 'Delimiter', sprintf('\0'));  % a 1x1 cell containing a 4x1 cell with the names
chanInfo.names = tmp{1};
return

% ===============================================================================
function [data, nPoints, markInfo] = doDataMsg(msg, chanInfo, dataOffset)
%	msg - uchar vector of:
%
% 	ULONG				nBlock;				// Block number, i.e. acquired blocks since acquisition started.
% 	ULONG				nPoints;			// Number of data points in this block
% 	ULONG				nMarkers;			// Number of markers in this data block
% 	short				nData[1];			// Data array -> short nData[nChannels * nPoints], multiplexed
% 	RDA_Marker			Markers[1];			// Array of markers -> RDA_Marker Markers[nMarkers]

blockNum = typecast(msg(1:4), 'uint32');	%% 4 bytes
nPoints = typecast(msg(5:8), 'uint32');
nMarkers = typecast(msg(9:12), 'uint32');
% disp(blockNum)
% number of channels (from the size of chanInfo struct)
numChannels = size(chanInfo.names,1);
% 2-byte data
len = 2 * numChannels * double(nPoints);		%% 2 bytes * num channels * num points
data = typecast(msg(13:13+len-1), 'int16');
try
	data = reshape(data, numChannels, nPoints);		%% one row for each channel, 1 col for each sample point
catch
% 	keyboard
end
% current position in the block
p = 13+len;

% markers
% 	ULONG				nSize;				// Size of this marker.
% 	ULONG				nPosition;			// Relative position in the data block.
% 	ULONG				nPoints;			// Number of points of this marker
% 	long				nChannel;			// Associated channel number (-1 = all channels).
% 	char				sTypeDesc[1];		// Type, description in ASCII delimited by '\0'.
markInfo = struct([]);
if nMarkers < 1, return; end
for i = 1:nMarkers
   markInfo(i).size = typecast(msg(p:p+3), 'uint32');
   p=p+4;
   markInfo(i).pos = typecast(msg(p:p+3), 'uint32');
   p=p+4;
   markInfo(i).nPoints = typecast(msg(p:p+3), 'uint32');
   p=p+4;
   markInfo(i).channel = typecast(msg(p:p+3), 'int32');
   p=p+4;
   % interpret the description and label of the marker
   %[desc, numCharRead] = textscan(char(msg(p:end)), '%s0' );     %% either 'Comment', 'Response', or 'Stimulus'
   % markInfo(i).desc = desc{:};
   [markInfo(i).desc, p] = read0termStr(msg, p);
   % textscan reads through the null byte separating the description and
   % label. i.e. it will return numCharRead as 13, but the
   % markInfo(i).desc = 'Comment', which is 7 chars.
   %p = p+length(markInfo(i).desc)+1;
   p = p+1;    % skip past the zero terminator
   if p > length(msg)
      disp(['reading in mark desc: p > length(msg): p = ' numstr(p) ...
         'length(msg) = ' length(msg)])
      %label = '';
      return
   end
   
   [markInfo(i).label, p] = read0termStr(msg, p);
   if i < nMarkers % there are more markers to read
      p = p+1;
      if p > length(msg)
         disp(['reading in mark label: p > length(msg): p = ' numstr(p) ...
            'length(msg) = ' length(msg)])
      end
   end
   
   %[label, numCharRead] = textscan(char(msg(p:end)), '%s0');
   %markInfo(i).label = label{:};
   %p = p+length(markInfo(i).label)+1;
end
return

% ================================================
function [str, newPos] = read0termStr(zeroTermStr, pos)
% read in from the message stream, the text corresponding to a text
% description or label.
% zeroTermStr - array of numbers corresponding to ascii character codes.
%      Values except 0 (which terminates a string) need to be converted
%      to a string
% pos - the position in the string to start reading, it should not be 0
% str - a string of the convertered characters read until a 0 is encountered
% newPos - the new position in the sent string of the encountered zero

% look at each character in zeroTermStr starting at pos
newPos = pos;
while newPos < length(zeroTermStr)
   if zeroTermStr(newPos) == 0     % encountered the zero
      break;
   end
   newPos = newPos+1;
end

str = char(zeroTermStr(pos:newPos));

return

