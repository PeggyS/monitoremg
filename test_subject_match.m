function is_match = test_subject_match(string_1, string_2)

if ~isempty(string_1) && ~isempty(string_2)
	%  find the subject in each string
	subj_1 = regexp(string_1, '([sc][\d]+\w+)', 'match');
	subj_1	= subj_1{1};

	subj_2 = regexp(string_2, '([sc][\d]+\w+)', 'match');
	subj_2	= subj_2{1};

	is_match = contains(subj_1, subj_2);
else
	is_match = false;
end
end