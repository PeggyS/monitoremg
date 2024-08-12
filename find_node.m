function node = find_node(tree, str)

node = [];

for n_cnt = 1:length(tree.Children)
	if strcmp(tree.Children(n_cnt).Text, str)
		node = tree.Children(n_cnt);
	end
end
return
end % function