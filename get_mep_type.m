function mep_type = get_mep_type(app)
% from the radiobutton group, find the tag of the one that is selected
mep_type = 'mep_pp'; % default type
rb_kids = app.h_radio_mep.Children;
for k_cnt = 1:length(rb_kids)
	if rb_kids(k_cnt).Value == 1
		mep_type = strrep(rb_kids(k_cnt).Tag, 'rb_', '');
		return
	end
end
