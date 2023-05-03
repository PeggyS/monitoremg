function confirmed = confirm_not_max_eff_so(max_tbl_so, saving_so)

mynl = newline;

q_str = ['\fontsize{14}You selected saving stimulator output, ' num2str(saving_so) ',' mynl ...
	'not the maximum stimulator output in the table, ' num2str(max_tbl_so) '.' mynl mynl...
	'Is this correct?'];
btn1 = 'Yes';
btn2 = 'No';
opts.Interpreter = 'tex';
opts.Default = btn2;
ans_button = questdlg(q_str, 'Save Info', btn1, btn2, opts);

switch ans_button
	case btn1
		confirmed = true;
	case btn2
		confirmed = false;
end
return
end