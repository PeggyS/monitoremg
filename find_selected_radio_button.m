function tag = find_selected_radio_button(h_radio)
tag = '';
for kk = 1:length(h_radio.Children)
	if h_radio.Children(kk).Value
		tag = h_radio.Children(kk).Tag; % tag of selected radio button
		return
	end
end
return