function update_muscle_panel(subj_str, app)

selectedNode = app.SubjectTree.SelectedNodes;

% show the subject and session
app.SubjectEditField_muscP.Value = subj_str;
app.SessionEditField_muscP.Value = selectedNode.Parent.Text;
app.MuscleEditField_muscP.Value = selectedNode.Text;

% is it rc or sici?
is_rc = false;
is_sici = false;
if contains(selectedNode.Text, '_rc')
	% rc
	is_rc = true;
	app.MEPMaxInfoPanel.Visible = 'on';
	app.SiciIcfInfoPanel.Visible = 'off';

elseif contains(selectedNode.Text, 'sici')
	% sici
	is_sici = true;
	app.MEPMaxInfoPanel.Visible = 'off';
	app.SiciIcfInfoPanel.Visible = 'on';
else
	app.MEPMaxInfoPanel.Visible = 'off';
	app.SiciIcfInfoPanel.Visible = 'off';
end

if is_rc == true
	update_mep_info(selectedNode, app)
end

if is_sici == true
	update_sici_info(selectedNode, app)
end

return
end