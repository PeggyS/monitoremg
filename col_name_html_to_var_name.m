function var_names = col_name_html_to_var_name(col_names)

var_names = cell(size(col_names));
for col_cnt = 1:length(col_names)
	switch col_names{col_cnt}
		case {'Epoch', 'Use'}
			var = col_names{col_cnt};
		case '<html><center>MagStim<br />Setting</center></html>'
			var = 'MagStim_Setting';
		case '<html><center>BiStim<br />Setting</center></html>'
			var = 'BiStim_Setting';
		case '<html><center>ISI<br />ms</center></html>'
			var = 'ISI_ms';
		case '<html><center>Effective<br />SO</center></html>'
			var = 'Effective_SO';
		case '<html><center>MEPAmpl<br />uVPp</center></html>'
			var = 'MEPAmpl_uVPp';
		case '<html><center>Is<br />MEP</center></html>'
			var = 'Is_MEP';
		case '<html><center>MEP<br />latency</center></html>'
			var = 'MEP_latency';
		case '<html><center>MEP<br />end</center></html>'
			var = 'MEP_end';
		case '<html><center>MEPAUC<br />uV*ms</center></html>'
			var = 'MEPAUC_uV_ms';
		case '<html><center>PreStimEmg<br />100ms</center></html>'
			var = 'PreStimEmg_100ms';
		case '<html><center>MonitorEMG<br />val</center></html>'
			var = 'MonitorEMGval';
		case '<html><center>Goal<br />EMG</center></html>'
			var = 'GoalEMG';
		case '<html><center>Goal<br />Min</center></html>'
			var = 'GoalEMGmin';
		case '<html><center>Goal<br />Max</center></html>'
			var = 'GoalEMGmax';
		case '<html><center>Stim<br />Type</center></html>'
			var = 'Stim_Type';
		case '<html><center>Comments</center></html>'
			var = 'comments';
	end
	var_names(col_cnt) = {var};
end

return
end