function updateDisplay_2mb(app, dataVec)
	% ------------------------------------------------------------
	%function updateDisplay(hFig, data, markInfo)
% 	function updateDisplay
	% inherited/used varables:
	%	handles - struct with object handles
	%	dataVec - the data vector
	%	markInfo - marker info struct
	%	peakTracker - peak tracking flag
	%	peakVal - peak value
	% hFig - handle to the figure (guidata has children object handles)
	% data is a vector of all the data in the block just received for the channel being displayed
	% markInfo - vector of structs (field label has the comment text)
	%handles = guidata(hFig);
	app.monitorEMGval = mean(abs(dataVec - mean(dataVec, 2)), 2);
%     disp(val)

	app.hLine_1.YData(2) = app.monitorEMGval(1);
	app.hLine_2.YData(2) = app.monitorEMGval(2);
% 	if ~isempty(markInfo)
% 		% fid = fopen('magstim_val.txt', 'r');
% 		% magstim_val = fscanf(fid, '%d');
% 		% fclose(fid);
% % 		magstim_val = app.magstim_mmap.Data(1);
% % 		bistim_val = app.magstim_mmap.Data(2);
% % 		isi_val = app.magstim_mmap.Data(3);
%         if strcmp(markInfo(1).label, ' ')
%             % msg = sprintf('Msg: %s, y = %3.1f, ms = %d', markInfo(1).desc, val, magstim_val);
%         else
%             % msg = sprintf('Msg: %s, y = %3.1f, ms = %d', markInfo(1).label, val, magstim_val);
%             msg = sprintf('emg = %4.0f', app.monitorEMGval);
% % 			msg = sprintf('emg = %4.0f, magstim = %d', app.monitorEMGval, magstim_val);
% 			%sprintf('magstim = %d, bistim = %d, isi = %d', magstim_val, bistim_val, isi_val)
% %             drawnow
%         end
% 		app.msgText.Text = msg;
% 
% 		app.hStarMark.Position = [0.3, app.monitorEMGval];
% 	end

% 	if app.peakTracker
%         % save val for sizeof(peakValVec) blocks of data
%         
%         
% 		app.peakValVec = circshift(app.peakValVec, [2 1]); % move all elements down
%         app.peakValVec(1) = app.monitorEMGval;                        % put new val at beginning
%         app.peakVal = mean(app.peakValVec);
% 
%         if app.peakVal > app.UIAxes_1.YLim(2)
%         	set(app.UIAxes_1, 'YLim', [ 0, app.peakVal * 1.1]);
% %         	drawnow
%         end
% 
%         set(app.hPeakLine, 'Visible', 'on')
%  		if std(app.peakValVec) < 50        % arbitrary threshold
% 			%set(handles.peakPatch, 'YData', [peakVal-5 peakVal-5 peakVal peakVal])
% 			set(app.hPeakLine, 'Color', 'g');
%             
%         else 
%             set(app.hPeakLine, 'Color', 'r');
%         end
%         set(app.hPeakLine, 'YData', [app.monitorEMGval app.monitorEMGval])
%         set(app.MVCEditField, 'Value', round(app.monitorEMGval));
% 
% 	end
	
	% change this to turn green when below threshold
% 	if app.monitorFlg
		if app.monitorEMGval(1) <= app.EMG_1_train_goal.Value 	%% in the green
			set(app.hLine_1, 'Color', [40 224 47]/255);
          
% 		elseif app.monitorEMGval > app.goalMax && ...
% 				app.monitorEMGval <= (app.goalVal + 0.1*app.peakVal)		%% slightly above (purple)
% 			set(app.hLine, 'Color', [170 100 245]/255);
%             app.inGreenFlag = false;
% 		elseif app.monitorEMGval > (app.goalVal + 0.1*app.peakVal)		%% far above goal (red)
% 			set(app.hLine, 'Color', [209 36 36]/255);
%             app.inGreenFlag = false;
% 		elseif app.monitorEMGval > (app.goalVal - 0.1*app.peakVal) && ...	%% slightly below (orange)
% 			app.monitorEMGval <= (app.goalVal - 0.05*app.peakVal)
% 			set(app.hLine, 'Color', [255 193 59]/255)
%             app.inGreenFlag = false;
		else
% 			set(app.hLine, 'Color', [239 245 71]/255)			%% far below goal (yellow)
			app.hLine_1.Color = [0 0.4470 0.7410];	%% default blue
%             app.inGreenFlag = false;
		end

% 		if app.monitorEMGval(2) <= app.EMG_2_rest_thresholdEditField.Value 	%% in the green
			app.hLine_2.Color = [40 224 47]/255;
% 		else
% 			app.hLine_2.Color = [0 0.4470 0.7410];
% 		end
% 	end

return
