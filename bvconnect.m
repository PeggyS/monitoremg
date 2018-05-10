function bvconnect
% bvconnect - connect to BrainVision via tcpip

tcpipinfo=instrhwinfo('tcpip')
% echotcpip('on', 4000)

% for debugging only
global t

% create tcpip object 
t = tcpip('192.168.1.118', 51234);	%% local machine & 16-bit port (32-bit port: 51244)

% configure object -- InputBufferSize
get(t, 'InputBufferSize');
set(t, 'InputBufferSize', 4000);

% configure object -- byteOrder
set(t, 'ByteOrder', 'littleEndian');

% connect
fopen(t)
% verify connection status
if ~strcmp(get(t, 'Status'), 'open'),
	disp('tcpip socket not open')
	return
end
tcpipinfo=instrhwinfo('tcpip')

% initialize variables
chanInfo = struct('resolution',[], 'names',{});
dataOffset = 0;

figure(1)
%hline = plot(0,0);
%set(gca, 'XLim', [0 1000]);
hb = bar(10);
set(gca,'xlim', [0.25 1.75])
set(gca,'ylim', [0 1000])

disp('ready to receive data')
while true,
	% get message from server
	[blockSize, msgType, msgBlock] = getMsgBlock(t);
%	fprintf('.');
%	data = fread(t, 1000, 'float32')

	switch msgType,
		case 1,		%% Start Message
			fprintf('\n');
			disp('Start recording')
			chanInfo = doStartMsg(msgBlock);
			dataOffset = 0;
		case 2,		%% Data Message
%			fprintf('\n');
%			disp('Read a block of data')
			[data, numPoints, markInfo] = doDataMsg(msgBlock, chanInfo);
%            disp([double(numPoints) double(data(1,1))*chanInfo.resolution(1)])
%            newData = [get(hline,'YData') double(data(1,:))*chanInfo.resolution(1)];
%            set(hline, 'YData', newData);
%            set(hline, 'XData', [1:length(newData)]);
            set(hb, 'ydata', mean(abs(double(data(1,:))*chanInfo.resolution(1))));
            if length(markInfo) > 0,
%            	line([dataOffset+markInfo(1).pos dataOffset+markInfo(1).pos], [-200 300], 'color', 'r');
%            	text(double(dataOffset+markInfo.pos), -150, markInfo(1).label{1}{:});
                text(0.3, 0.5, markInfo(1).label{:});
			end
            	
            drawnow;
			dataOffset = dataOffset + numPoints;
		case 3,		%% Stop Message
			disp('Stop recording')
			fprintf('\n');
	end
end

% Binary Read Properties -- ValuesReceived
% The ValuesReceived property is updated by the number of values read from the server.
get(t, 'ValuesReceived')

% Cleanup
fclose(t);
delete(t);
clear t

% echotcpip('off')

% ------------------------------------------------------------
function [blockSize, msgType, msgBlock] = getMsgBlock(t)

% message header:
%	guid		16 bytes (unique identifier) 8E45584396C9864CAF4A98BBF6C91450
%	blockSize	'ulong' size of msg block in bytes including this header
%	msgType		'ulong' message type {1-start; 2-data; 3-stop}

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

% ------------------------------------------------------------
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

% ------------------------------------------------------------
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

% number of channels (from the size of chanInfo struct)
numChannels = size(chanInfo.names,1);
% 2-byte data 
len = 2 * numChannels * nPoints;		%% 2 bytes * num channels * num points
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
	[desc, numCharRead] = textscan(char(msg(p:end)), '%s');     %% either 'Comment', 'Response', or 'Stimulus'
    markInfo(i).desc = desc{:};
    % textscan reads through the null byte separating the description and
    % label. i.e. it will return numCharRead as 13, but the
    % markInfo(i).desc = 'Comment', which is 8 chars.
	p = p+length(markInfo(i).desc{:})+1;
    [label, numCharRead] = textscan(char(msg(p:end)), '%s');
    markInfo(i).label = label{:};
    p = p+length(markInfo(i).label{:})+1;
end