function out = readtxtfile(fname)
%READTXTFILE Read in a plain text file; return cell array of strings
%	C = READTXTFILE(FILENAME) reads in a plain text file with the name FILENAME and returns a
%	cell array of strings C with one row for each line of the file. Blank lines are removed.

%	Created: Peggy Skelly 2013-01-11

% open the file
if ~exist(fname, 'file')
	error([fname ' not found']);
end
fid = fopen(fname);

% read in the text
txt = textscan(fid,'%s', 'delimiter', '\n');
out = txt{1};
% remove lines of 0 length
out = out(cellfun(@length, out) ~= 0);

% close the file
fclose(fid);
