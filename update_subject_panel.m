function update_subject_panel(subj_str, app)

selectedNode = app.SubjectTree.SelectedNodes;

% show the subject
app.SubjectEditField_subjP.Value = subj_str;

node_names = cell(1, length(selectedNode.Children));
for n_cnt = 1:length(selectedNode.Children)
	node_names{n_cnt} = selectedNode.Children(n_cnt).Text;
end
% missing sessions
missing_session_msk = ~ismember(app.expected_sessions, node_names);
missing_session_list = app.expected_sessions(missing_session_msk);
if ~isempty(missing_session_list)
	app.MissingSessionsTextArea.Value = missing_session_list';
else
	app.MissingSessionsTextArea.Value = '';
end


extra_session_msk = ~ismember(node_names, app.expected_sessions);
extra_session_list = node_names(extra_session_msk);
if ~isempty(extra_session_list)
	app.ExtraSessionsTextArea.Value = extra_session_list';
else
	app.ExtraSessionsTextArea.Value = '';
end


return
end