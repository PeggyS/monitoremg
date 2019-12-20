function [m_max, m_auc, m_dur] = parse_mmax_file(mmax_fname, session, muscle)
% read the excel/csv file with m-max info, extract the m-max, auc, and m-wave duration
% for the session & muscle

m_max = 1;
m_auc = 1;
m_dur = 1;

if isempty(mmax_fname) || isempty(session) || isempty(muscle)
	return
end

m_tbl = readtable(mmax_fname, 'datelocale', '%{MM/dd/uuuu}D');
m_tbl.Properties.VariableNames = lower(m_tbl.Properties.VariableNames);

m_tbl.session = nominal(m_tbl.session);
m_tbl.side = nominal(lower(m_tbl.side));
m_tbl.muscle = nominal(lower(m_tbl.muscle));

side = '';
musc = '';
tmp = regexpi(muscle, '(inv)|(uninv)', 'match');
if ~isempty(tmp)
	side = tmp{1};
	musc = strrep(muscle, [side '_'], '');
else
	beep
	disp(['unknown side in muscle ' muscle])
	return
end


m_max = table2array(m_tbl(m_tbl.session == session & m_tbl.side == side & m_tbl.muscle == musc,{'mep_ampl_uv'}));

try
	m_auc = table2array(m_tbl(m_tbl.session == session & m_tbl.side == side & m_tbl.muscle == musc,{'mep_auc_uvms'}));
catch
	disp('%s does not have mep_auc_uvms variable.', mmax_fname)
end

try
	m_dur = table2array(m_tbl(m_tbl.session == session & m_tbl.side == side & m_tbl.muscle == musc,{'mep_dur_ms'}));
catch
	disp('%s does not have mep_dur_ms variable.', mmax_fname)
end