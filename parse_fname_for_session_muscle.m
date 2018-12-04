function [session, muscle] = parse_fname_for_session_muscle(fname)
% look for the session (pre, mid, post, followup, week1, week5, etc) and
% the muscle (inv_ta, uninv_gastroc, inv_flexors, uninv_extensors, etc) 
% in the filename of the emg_data.txt file

session = '';
muscle = '';

tmp = regexpi(fname, '(pre)|(post)|(mid)|(followup)|(week\d+)', 'match');
if ~isempty(tmp)
	session = tmp{1};
end

side = '';
tmp = regexpi(fname, '(inv)|(uninv)', 'match');
if ~isempty(tmp)
	side = tmp{1};
end

musc = '';
tmp = regexpi(fname, '(ta)|(gastroc)|(flexors)|(extensors)', 'match');
if ~isempty(tmp)
	musc = tmp{1};
end

if ~isempty(side) && ~isempty(musc)
	muscle = [side '_' musc];
end
