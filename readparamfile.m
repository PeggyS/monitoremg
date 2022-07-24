function param = readparamfile(varargin)
%READPARAMFILE read and parse the parameter file for keywords returning a cell
%	of corresponding values
%	PARAMCAS = READPARAMFILE(PFILENAME, KEYWORDS) reads in the plain text file 
%	PFILENAME. The text is parsed to extract the keywords and return a cell 
%	array of strings of the values PARAMCAS. KEYWORDS is a cell array of strings
%	of the keywords (characters) that must appear before the colon on a line
% 	in the parameter file. The string after the colon on that line is the 
%	returned value in PARAMCAS. If a keyword is not found in the file, then
%	an empty matrix is returned for that value.
%
%	PARAMCELL = READPARAMFILE(PFILENAME, KEYWORDS, DEFAULT) reads in the file
%	interpreting keyword-value pairs as above. In addition the default cell
%	array is used to interpret if the value is a number or a string. If it is
%	a number, then the value-string is converted to a number. If the keyword
%	does not appear in the file, then the default value is returned in the
%	cell array of values PARAMCELL.

%	Created by: Peggy Skelly 2013-01-11
%

% parse the input argument
if nargin < 2
	error('readparamfile requires at least 2 input arguments');
end
pfile = varargin{1};
keywords = varargin{2};
default = [];
if nargin > 2
	default = varargin{3};
	if length(keywords) ~= length(default)
		error('KEYWORDS and DEFAULT arguments to readparamfile must be equal lengths');
	end
end

% default output
param = cell(1, length(keywords));

% read in the text file
txt = readtextfile(pfile); 	% cell array of strings, one row for each line in the file

% separate each line at the colon ' : '
% txt = cellfun(@(x)(regexp(x,' : ','split')), txt, 'uniformoutput', false);
txt = split(txt, ' : ');

% look for each keyword
foundMsk = false(size(txt,1),1);

for i = 1:length(keywords)
	% find the keyword in col 1 of txt cell
	for cnt = 1:size(txt,1)
		if strcmp(txt{cnt,1}, keywords{i})
			foundMsk(cnt) = true;
		else
			foundMsk(cnt) = false;
		end
	end

% 	c = cellfun(@(x)(strfind(lower(x{1}), lower(keywords{i}))), txt, 'uniformoutput', false);

    % which row in txt?
%     foundMsk = ~cellfun(@isempty,c);
    
    switch sum(foundMsk)
        case 0       % keyword not found
            param{i} = [];
        case 1
%             param{i} = strtrim(txt{foundMsk}{2});
			param{i} = strtrim(txt{foundMsk, 2});
        otherwise           % more than one instance of the keyword found
            error(['more than one instance of keyword ' keywords{i} ' found']);
    end
end

if ~isempty(default)
	
	% apply default values
	msk = cellfun(@isempty, param);
	param(msk) = default(msk);
	
	for i = 1:length(param)
		
		if ischar(param{i}) && isnumeric(default{i}) % convert strings to number if default is a number
			param{i} = str2num(param{i}); %#ok<ST2NM> 
		end
	end
end
