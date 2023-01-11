function confirmed = confirm_single_row_save(selected_epochs)

mynl = newline;

q_str = ['\fontsize{14}Only one row was selected to save for MEP latency.' mynl ...
	'Row ' num2str(selected_epochs(1)) mynl mynl ...
	'Is this correct?'];
btn1 = 'Yes';
btn2 = 'No';
opts.Interpreter = 'tex';
opts.Default = btn2;
ans_button = questdlg(q_str, 'Save File', btn1, btn2, opts);

switch ans_button
	case btn1
		confirmed = true;
	case btn2
		confirmed = false;
end

return
end