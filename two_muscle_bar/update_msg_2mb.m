function update_msg_2mb(app,markInfo)


if ~isempty(markInfo)
    % fid = fopen('magstim_val.txt', 'r');
    % magstim_val = fscanf(fid, '%d');
    % fclose(fid);
    % 		magstim_val = app.magstim_mmap.Data(1);
    % 		bistim_val = app.magstim_mmap.Data(2);
    % 		isi_val = app.magstim_mmap.Data(3);
%     if strcmp(markInfo(1).label, ' ')
        msg = sprintf('Msg: %s', string(markInfo(1).desc(1:end-1)'));
%     else
%         % msg = sprintf('Msg: %s, y = %3.1f, ms = %d', markInfo(1).label, val, magstim_val);
%         msg = sprintf('emg = %4.0f', app.monitorEMGval);
%         % 			msg = sprintf('emg = %4.0f, magstim = %d', app.monitorEMGval, magstim_val);
%         %sprintf('magstim = %d, bistim = %d, isi = %d', magstim_val, bistim_val, isi_val)
%         %             drawnow
%     end
    app.msgText.Text = msg;

%     app.hStarMark.Position = [0.3, app.monitorEMGval];
end