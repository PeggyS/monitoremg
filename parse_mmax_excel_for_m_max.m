function m_max = parse_mmax_excel_for_m_max(mmax_fname, session, muscle)
% read the excel file with m-max, extract the m-max for the session & muscle

m_max = 1;

if isempty(mmax_fname) || isempty(session) || isempty(muscle)
	return
end

m_tbl = readtable(mmax_fname);
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

	