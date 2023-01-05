function chkbox_mep_verified_callback(evt, ~, app) 

if evt.Value == 1 % box got checked
	% put info in the emg data figure
	app.h_edit_mep_verified_by.String = upper(app.user_initials);
	app.h_edit_mep_verified_when.String = datestr(now, 'yyyy-mm-dd HH:MM:SS');
	% append the info to the mep_computed_info.txt file
	app.mep_info.verified_by = app.h_edit_mep_verified_by.String;
	app.mep_info.verified_when = app.h_edit_mep_verified_when.String;
else % unchecked
	% remove info emg data figure
	app.h_edit_mep_verified_by.String = '';
	app.h_edit_mep_verified_when.String = '';
	% blank the info to the mep_computed_info.txt file
	app.mep_info.verified_by = app.h_edit_mep_verified_by.String;
	app.mep_info.verified_when = app.h_edit_mep_verified_when.String;
end

return
end % chkbox_mep_verified_callback