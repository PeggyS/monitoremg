function mep_button_selection(source,event, app)
% disp(['Previous: ' event.OldValue.String]);
% disp(['Current: ' event.NewValue.String]);
% disp('------------------');

switch event.NewValue.String
	case 'Area Under the Curve'
		app.h_emg_auc_patch.Visible = 'on';
	case 'Peak-to-Peak'
		app.h_emg_auc_patch.Visible = 'off';
end