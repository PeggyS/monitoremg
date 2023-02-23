function update_session_panel(subj_str, app)

selectedNode = app.SubjectTree.SelectedNodes;

% show the subject and session
app.SubjectEditField_sessP.Value = subj_str;
app.SessionEditField_sessP.Value = selectedNode.Text;


node_names = cell(1, length(selectedNode.Children));
for n_cnt = 1:length(selectedNode.Children)
	node_names{n_cnt} = selectedNode.Children(n_cnt).Text;
end

% missing files
missing_file_msk = ~ismember(app.expected_analysis_files, node_names);
missing_file_list = app.expected_analysis_files(missing_file_msk);
if ~isempty(missing_file_list)
	app.MissingFilesTextArea.Value = missing_file_list';
else
	app.MissingFilesTextArea.Value = '';
end

return
end