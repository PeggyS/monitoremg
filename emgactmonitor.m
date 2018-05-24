function emgactmonitor(varargin)
%EMGACTMONITOR Monitor EMG activity via tcpip connection to BrainVision Recorder
%
%	EMGACTMONITOR displays a bar graph whose height corresponds to the EMG activity
%	level being recording in BrainVision Recorder. 
%
%	EMGACTMONITOR(PARAMFILE) reads in the parameters from the text file PARAMFILE. 
%	Each line of the file contains a parameter-value pair. The parameter is identified
%	by its keyword. Additional words and spaces may be added to a parameter to enhance
%	readability. The parameter and value are separated by a colon (:). The following
%	parameter-value pairs are the same:
%		sample frequency : 2500
%		sampling frequency in hertz : 2500
%	The keyword for this parameter is FREQ. It appears in both lines. Case does not matter. %	No 2 parameters/lines in the file should contain the same keyword. If parameters are
%	not specified, the default value is used.
%
%	The following parameters identified by the keyword may be defined:
%		ip address (keyword: ADDR) - the ip address of the computer running 
%			BrainVision Recorder (default = 192.168.1.102)
%		sampling frequency (keyword: FREQ) - the sampling frequency of data monitoring
%			in BrainVision Recorder (default = 2500)
%		averaging time period (keyword: PERIOD) - the time duration in sec for the signal to
%			be averaged and displayed. Longer times produce a slower, smoother moving 
%			display. Shorter times produce a very fast and jittery looking display.
%			(default = 0.5)
%		emg channel (keyword: CHAN) - the channel number from Recorder to display. Must be
%			a number between 1 and 8. (default = 1)
%		activation goal (keyword: GOAL) - the activity level as a fraction of the maximum
%			voluntary contraction (MVC) that will be the target for coloring the bar graph.
%			(default = 0.2)

% Created by: Peggy Skelly 2013-01-10
%	time required: approx. 3 days a while ago to get communication (remote data access)
%		from Brainsight established plus a preliminary gui.
%		2013-01-08: 7 hrs working on gui, but discovered it's too slow (too long of a lag
%			time between activation changes and events and display changes in Matlab)
%		2013-01-09: 8 hrs rework of gui from barebones - had to go with line objects
%			instead of patch objects due to Matlab display update time.
%		2013-01-10: 10:30-1:30: added messages at bottom of display, channel choice 
%			popup menu, close confirm dialog box. 4:30-6:00 : added goal activation 
%			percent/fraction edit text object; defining and getting parameter file as input 
%			4.5 hrs
%		2013-01-11: 4 hrs: reading parameters from file including provision for defaults
%		total: 6 days
%		2013-01-23: 1 hr: adding edit box to set goal
%
%	todo:
%		- add variable input parameters so different parameters can be defined:
%			ip address, initial channel number (default = 1), percent activation 
%			goal (default = 0.2), brainvision sampling rate (default = 2500 Hz),
%			time duration to average for (default = 0.5 sec) - specified in an op
%			@done(2013-01-11)
%		- add close confirmation box @done(2013-01-10)

% input parameter file 
defaults = {'192.168.1.102', 2500, 0.5, 1, 0.2};
if nargin > 0,
	pfile = varargin{1};	%% 1st and only argument is the parameter file
	if ~exist(pfile, 'file'),
		msg = sprintf('Only input to EMGACTMONITOR is a paramter text file. The file %s cannot be found.', ...
            upper(pfile));
		error(msg);
	end
	% read in the parameter file
	keywords = {'addr' 'freq' 'period' 'chan' 'goal'};
	params = readparamfile(pfile, keywords, defaults);
else
	params = defaults;
end
% make variables from params cell array
[ipAddr, sampFreq, avgPeriod, dispChan, goalPct] = deal(params{:});

% create tcpip object 
tcp_port = tcpip(ipAddr, 51234);	%% local machine & 16-bit port (32-bit port: 51244)

% configure object -- InputBufferSize
get(tcp_port, 'InputBufferSize');
set(tcp_port, 'InputBufferSize', 2000);

% configure object -- byteOrder
set(tcp_port, 'ByteOrder', 'littleEndian');

% connect
% % === DEBUG - comment out to run without communicating with Recorder
% fopen(t);		
% % verify connection status
% if ~strcmp(get(t, 'Status'), 'open'),
% 	disp('tcpip socket not open')
% 	return
% end
% === end DEBUG

tcpipinfo=instrhwinfo('tcpip')

% initialize variables
chanInfo = struct('resolution',[], 'names',{});
dataVec = zeros(round(sampFreq*avgPeriod),1);	%% 0.5 sec of data when BrainVision Recorder is sampling at 2500 Hz

% initialize the figure
%scrSize = get(0, 'ScreenSize');
width = 200; height = 1100;
hFig = figure('Position', [1 100 width height]);
set(hFig, 'Menubar', 'none');
%set(hFig, 'Position', [1650 129 200 800]);
handles.hAx = axes('Position', [0.1944    0.1515    0.6865    0.8213]);
set(handles.hAx,'xlim', [0.25 1.75]);
set(handles.hAx,'ylim', [0 300]);
set(handles.hAx,'XTick', []);
%handles.hPatch = patch([0.5 1.5 1.5 0.5], [0 0 1 1], 'b');
handles.hLine = line([1 1], [0 1]);
set(handles.hLine, 'LineWidth', 50);


% message display text
handles.txtMessage = uicontrol('Style', 'text', 'String', 'no messae', ...
	'Position', [20 134 160 20], 'BackgroundColor', [0.8 0.8 0.8]);
hTxt = [];

% axes limit edit box
handles.edYmax = uicontrol('Style', 'edit', 'String', '300', ...
	'Position', [73 103 40 23], 'Callback', @yMaxCallback, ...
    'BackgroundColor', [0.8 0.8 0.8]);
handles.txtYmax = uicontrol('Style', 'text', 'String', 'Ymax =', ...
	'Position', [20 102 50 20], 'BackgroundColor', [0.8 0.8 0.8]);
yMax = 300;

% monitor or show goal check box. Checked = 1 draw the goal and color bar green when in the zone
handles.monitorChkbx = uicontrol('Style', 'checkbox', 'String', 'Show Goal', 'Value', 0, ...
	'Position', [20 82 100 20], 'Callback', @monitorCallback);
monitorFlg = false;
handles.edGoal = uicontrol('Style', 'edit', 'String', num2str(goalPct), ...
	'Position', [112 80 37 23], 'Callback', @edGoalCallback, ...
	'BackgroundColor', [0.8 0.8 0.8]);
handles.txtGoal = uicontrol('Style', 'text', 'String', 'x MVC', ...
	'Position', [145 78 47 20], 'BackgroundColor', [0.8 0.8 0.8]);

% track the peak
handles.peakChkbx = uicontrol('Style', 'checkbox', 'String', 'Mark MVC', 'Value', 1, ...
	'Position', [20 60 100 20], 'Callback', @peakCheckCallback);
peakTracker = true;
handles.pbResetPeak = uicontrol('Style', 'pushbutton', 'String', 'Reset', ...
	'Position', [115 60 50 20], 'Callback', @resetPeakCallback);
peakValVec = zeros(1,100);
peakVal = 0;

% mvc setting edit box
handles.edMvc = uicontrol('Style', 'edit', 'String', num2str(peakVal), ...
	'Position', [166 58 34 23], 'Callback', @edMvcCallback, ...
	'BackgroundColor', [0.8 0.8 0.8]);
% the peak line in the axes
handles.peakLine = line([0.5 1.5], [peakVal peakVal]);
set(handles.peakLine, 'LineWidth', 20, 'Color', [209 36 36]/255);
	
% channel choice - popup menu
handles.popChannel = uicontrol('Style', 'popup', 'String', '1|2|3|4|5|6|7|8', ...
	'Value', dispChan, ...
	'Position', [112 39 58 18], 'Callback', @popChannelCallback);

handles.txtChan = uicontrol('Style', 'text', 'String', 'EMG Channel:', ...
	'Position', [15 34 100 20], 'BackgroundColor', [0.8 0.8 0.8]);

% quit/close button
handles.pbQuit = uicontrol('Style', 'pushbutton', 'String', 'Close', ...
	'Position', [75 10 50 20], 'Callback', @quitCallback);
quitFlg = false;

% save object handles in the figure struct
% guidata(hFig, handles);


disp('ready to receive data')
drawnow;
% 10 Hz hp filter
[b, a] = butter(4, 10/(sampFreq/2), 'high');

while ~quitFlg
	% get message from server
	[blockSize, msgType, msgBlock] = getMsgBlock(tcp_port);
%	fprintf('.');
%	data = fread(t, 1000, 'float32')

	switch msgType
		case 0		%% no socket open, not reading data
			% no nothing
		case 1		%% Start Message
			disp('Detected BrainVision Start Monitoring')
			chanInfo = doStartMsg(msgBlock);

		case 2		%% Data Message
%			fprintf('\n');
%			disp('Read a block of data')
			[data, numPoints, markInfo] = doDataMsg(msgBlock, chanInfo);
			% put new data into the data vector
			dataVec = circshift(dataVec, double(numPoints));
            newData = filtfilt(b,a,double(data(dispChan,:)'));
			dataVec(1:numPoints) = newData*chanInfo.resolution(dispChan);
			%updateDisplay(hFig, double(data(1,:))*chanInfo.resolution(1), markInfo);
            updateDisplay;	

		case 3		%% Stop Message
			disp('Detected BrainVision Stop Monitoring')

	end
	drawnow;
end

% Binary Read Properties -- ValuesReceived
% The ValuesReceived property is updated by the number of values read from the server.
disp(['Values read = ' num2str(get(tcp_port, 'ValuesReceived'))])
disp('Closing connection')
% Cleanup
fclose(tcp_port);
delete(tcp_port);
clear t
delete(hFig)

disp('done')
% echotcpip('off')

	% ------------------------------------------------------------
	%function updateDisplay(hFig, data, markInfo)
	function updateDisplay
	% inherited/used varables:
	%	handles - struct with object handles
	%	dataVec - the data vector
	%	markInfo - marker info struct
	%	peakTracker - peak tracking flag
	%	peakVal - peak value
	% hFig - handle to the figure (guidata has children object handles)
	% data is a vector of all the data in the block just received for the channel being displayed
	% markInfo - vector of structs (field label has the comment text)
	%handles = guidata(hFig);
	val = mean(abs(dataVec - mean(dataVec)));
%     disp(val)
%	set(handles.hPatch, 'YData', [0 0 val val]);
	set(handles.hLine, 'YData', [0 val]);
	if ~isempty(markInfo)
        if strcmp(markInfo(1).label, ' ')
            msg = sprintf('Msg: %s; y = %3.1f', markInfo(1).desc, val);
        else
            msg = sprintf('Msg: %s; y = %3.1f', markInfo(1).label, val);
        end
		set(handles.txtMessage, 'String', msg);
% 		if ~isempty(hTxt)
% 			delete(hTxt); 
% 			hTxt = [];
% 		end
		hTxt = text(0.3, val, '*');
	end

	if peakTracker
        % save val for sizeof(peakValVec) blocks of data
        
        peakValVec = circshift(peakValVec, [2 1]); % move all elements down
        peakValVec(1) = val;                        % put new val at beginning
        peakVal = mean(peakValVec);
 		if std(peakValVec) < 50        % arbitrary threshold
			%set(handles.peakPatch, 'YData', [peakVal-5 peakVal-5 peakVal peakVal])
			set(handles.peakLine, 'Color', 'g');
            
        else 
            set(handles.peakLine, 'Color', 'r');
        end
        set(handles.peakLine, 'YData', [val val])
        set(handles.edMvc, 'String', num2str(round(val)));
	end
	
	if monitorFlg
		if val >= (goalPct*peakVal - 0.05*peakVal) && ...
			val <= (goalPct*peakVal + 0.05*peakVal)		%% in the green
			set(handles.hLine, 'Color', [40 224 47]/255);
		elseif val > (goalPct*peakVal + 0.05*peakVal) && ...
				val <= (goalPct*peakVal + 0.1*peakVal)		%% slightly above (purple)
			set(handles.hLine, 'Color', [170 100 245]/255);
		elseif val > (goalPct*peakVal + 0.1*peakVal)		%% far above goal (red)
			set(handles.hLine, 'Color', [209 36 36]/255);
		elseif val > (goalPct*peakVal - 0.1*peakVal) && ...	%% slightly below (orange)
			val <= (goalPct*peakVal - 0.05*peakVal)
			set(handles.hLine, 'Color', [255 193 59]/255)
		else
			set(handles.hLine, 'Color', [239 245 71]/255)			%% far below goal (yellow)
		end
	end

	end

	% ------------------------------------------------------------
	function drawGoal
		%if isfield(handles, 'hGoalLines'), 
		%	delete(handles.hGoalLines(:)); 
		%	delete(handles.hGoalLines);
		%end
        removeGoal;
		goalVal = goalPct * peakVal;
		handles.hGoalLines(1) = line([0.25 1.75], [goalVal goalVal]);
        set(handles.hGoalLines(1), 'LineWidth', 5)
		%if isfield(handles, 'hGoalPatch'), delete(handles.hGoalPatch); end
		goalMin = goalVal - 0.05*peakVal;
		goalMax = goalVal + 0.05*peakVal;
		handles.hGoalLines(2) = line([0.25 1.75], [goalMin goalMin]);
		handles.hGoalLines(3) = line([0.25 1.75], [goalMax goalMax]);
		set(handles.hGoalLines(2:3), 'LineStyle', '--', 'LineWidth', 3); 
	end
	% ------------------------------------------------------------
	function removeGoal
		if isfield(handles, 'hGoalLines') && ~isempty(handles.hGoalLines), 
			delete(handles.hGoalLines(:)); 
			handles.hGoalLines = [];
		end
		set(handles.hLine, 'Color', [0.1 0.1 1])
	end
	% ------------------------------------------------------------
	function quitCallback(hObj, evt)
		% confirm quitting
		confirm = questdlg('Are you sure you want to quit?', 'Quit Confirmation', ...
			'Yes', 'No', 'No');
		if strcmp(lower(confirm), 'yes'),
			quitFlg = true;
		end
	end
	% ------------------------------------------------------------
	function yMaxCallback(hObj, evt)
		yMax = str2double(get(hObj, 'String'));
		set(handles.hAx, 'YLim', [0 yMax]);
	end
	% ------------------------------------------------------------
	function peakCheckCallback(hObj, evt)	% Mark MVC check box
		peakTracker = get(hObj, 'Value');
		if peakTracker,
			set(handles.pbResetPeak, 'Enable', 'on');
		else
			set(handles.pbResetPeak, 'Enable', 'off');
		end
		%set(handles.monitorChkbx, 'Value', ~peakTracker);
	end
	% ------------------------------------------------------------
	function resetPeakCallback(hObj, evt)
		peakVal = 0;
        peakValVec = zeros(size(peakValVec));
	end
	% ------------------------------------------------------------
	function monitorCallback(hObj, evt)
		monitorFlg = get(hObj, 'Value');
		%set(handles.peakChkbx, 'Value', ~monitorFlg);
		if monitorFlg,
			drawGoal;
			yMax = max(ceil(goalPct * peakVal * 2), 1);
			set(handles.edYmax, 'String', num2str(yMax));
			set(handles.hAx, 'YLim', [0 yMax]);
		else
			removeGoal;
			yMax = max(ceil(1.2 * peakVal), 1);
			set(handles.edYmax, 'String', num2str(yMax));
			set(handles.hAx, 'YLim', [0 yMax]);
		end
	end
	% ------------------------------------------------------------
	function edGoalCallback(hObj, evt)
		goalPct = str2double(get(hObj, 'String'));
	end
	% ------------------------------------------------------------
	function edMvcCallback(hObj, evt)
		peakVal = str2double(get(hObj, 'String'));
		set(handles.peakLine, 'YData', [peakVal peakVal]);
		monitorCallback(handles.monitorChkbx, []);
	end
	% ------------------------------------------------------------
	function popChannelCallback(hObj, evt)
		dispChan = get(hObj, 'Value');
%		display(dispChan);
	end
	
end		%% monitor2

% ===============================================================================
function [blockSize, msgType, msgBlock] = getMsgBlock(t)
% message header:
%	guid		16 bytes (unique identifier) 8E45584396C9864CAF4A98BBF6C91450
%	blockSize	'ulong' size of msg block in bytes including this header
%	msgType		'ulong' message type {1-start; 2-data; 3-stop}

blockSize = []; msgType = 0; msgBlock = [];
if ~strcmp(get(t, 'Status'), 'open'),
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
if blockSize > 0,
	msgBlock = int8(fread(t, blockSize, 'int8'));
%    disp(msgBlock(1:4))
%    size(msgBlock)
end

% get(t, 'ValuesReceived');
end

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
len = nChannels * 8;							%% 8 bytes per channel
chanInfo.resolution = typecast(msg(13:13+len-1), 'double');		%% resolution for each channel

% channel names
chanInfo.names = cell(nChannels,1);		%% initialize
p = 13+len;	%% position in byte block
% parse the names out of the msg block
for i = 1:nChannels,
	[name, numCharRead] = textscan(char(msg(p:end)), '%s'); %% p is the end of the last scanned character
	% textscan reads past the null char separating the channel names, so do not uses numCharRead
	chanInfo.names(i) = name{:};
	p = p+length(chanInfo.names{i})+1;	%% move past the null byte to the beginning next string
	% check that we haven't gone too far
	if p > length(msg), return; end
end
end

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
data = reshape(data, numChannels, nPoints);		%% one row for each channel, 1 col for each sample point

% current position in the block
p = 13+len;

% markers
% 	ULONG				nSize;				// Size of this marker.
% 	ULONG				nPosition;			// Relative position in the data block.
% 	ULONG				nPoints;			// Number of points of this marker
% 	long				nChannel;			// Associated channel number (-1 = all channels).
% 	char				sTypeDesc[1];		// Type, description in ASCII delimited by '\0'.
markInfo = [];
if nMarkers < 1, return; end
for i = 1:nMarkers,
	markInfo(i).size = typecast(msg(p:p+3), 'uint32');
	p=p+4;
	markInfo(i).pos = typecast(msg(p:p+3), 'uint32');
	p=p+4;
	markInfo(i).nPoints = typecast(msg(p:p+3), 'uint32');
	p=p+4;
	markInfo(i).channel = typecast(msg(p:p+3), 'int32');
	p=p+4;
    % interpret the description and label of the marker
%	[desc, numCharRead] = textscan(char(msg(p:end)), '%s0' );     %% either 'Comment', 'Response', or 'Stimulus'
%    markInfo(i).desc = desc{:};
    [markInfo(i).desc p] = read0termStr(msg, p);
    % textscan reads through the null byte separating the description and
    % label. i.e. it will return numCharRead as 13, but the
    % markInfo(i).desc = 'Comment', which is 7 chars.
	%p = p+length(markInfo(i).desc)+1;
    p = p+1;    % skip past the zero terminator 
    if p > length(msg)
        disp(['reading in mark desc: p > length(msg): p = ' numstr(p) ...
            'length(msg) = ' length(msg)])
        label = '';
        return
    end
    
    [markInfo(i).label p] = read0termStr(msg, p);
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
end

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

end
