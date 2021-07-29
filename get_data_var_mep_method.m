function [data_var, mep_method] = get_data_var_mep_method(app)
% default values:
data_var = 'MEPAmpl_uVPp';
mep_method = 'p2p';

% running an app with the radio buttons to choose which method
if isprop(app, 'h_radio_mep')
	tag = find_selected_radio_button(app.h_radio_mep);
	switch tag
		case 'rb_mep_ampl'
			data_var = 'MEPAmpl_uVPp';
			mep_method = 'p2p';
		case 'rb_mep_auc'
			data_var = 'MEPAUC_uV_ms';
			mep_method = 'auc';
	end

end