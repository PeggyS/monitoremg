function update_mmax_info(app)
[m_max, m_auc, m_dur] = parse_mmax_file(app.MMaxFileEditField.Value, ...
	app.SessionEditField.Value, app.MuscleEditField.Value);
if isnan(m_max)
	m_max =  1;
end
app.MmaxEditField.Value = m_max;
if isnan(m_auc)
	m_auc =  1;
end
app.MaucEditField.Value = m_auc;
if isnan(m_dur)
	m_dur =  1;
end
app.MwaveDurationEditField.Value = m_dur;

return