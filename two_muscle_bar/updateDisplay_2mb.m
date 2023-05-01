function updateDisplay_2mb(app, dataVec, markInfo)
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
	app.monitorEMGval = mean(abs(dataVec - mean(dataVec)));
%     disp(val)

	set(app.hLine_1, 'YData', [0 app.monitorEMGval(1)]);
	set(app.hLine_2, 'YData', [0 app.monitorEMGval(2)]);
	if ~isempty(markInfo)
		% fid = fopen('magstim_val.txt', 'r');
		% magstim_val = fscanf(fid, '%d');
		% fclose(fid);
		magstim_val = app.magstim_mmap.Data(1);
		bistim_val = app.magstim_mmap.Data(2);
		isi_val = app.magstim_mmap.Data(3);
        if strcmp(markInfo(1).label, ' ')
            % msg = sprintf('Msg: %s, y = %3.1f, ms = %d', markInfo(1).desc, val, magstim_val);
        else
            % msg = sprintf('Msg: %s, y = %3.1f, ms = %d', markInfo(1).label, val, magstim_val);
            msg = sprintf('emg = %4.0f', app.monitorEMGval);
% 			msg = sprintf('emg = %4.0f, magstim = %d', app.monitorEMGval, magstim_val);
			%sprintf('magstim = %d, bistim = %d, isi = %d', magstim_val, bistim_val, isi_val)
%             drawnow
        end
		app.msgText.Text = msg;

		app.hStarMark.Position = [0.3, app.monitorEMGval];
	end

	if app.peakTracker
        % save val for sizeof(peakValVec) blocks of data
        
        
		app.peakValVec = circshift(app.peakValVec, [2 1]); % move all elements down
        app.peakValVec(1) = app.monitorEMGval;                        % put new val at beginning
        app.peakVal = mean(app.peakValVec);

        if app.peakVal > app.UIAxes_1.YLim(2)
        	set(app.UIAxes_1, 'YLim', [ 0, app.peakVal * 1.1]);
%         	drawnow
        end

        set(app.hPeakLine, 'Visible', 'on')
 		if std(app.peakValVec) < 50        % arbitrary threshold
			%set(handles.peakPatch, 'YData', [peakVal-5 peakVal-5 peakVal peakVal])
			set(app.hPeakLine, 'Color', 'g');
            
        else 
            set(app.hPeakLine, 'Color', 'r');
        end
        set(app.hPeakLine, 'YData', [app.monitorEMGval app.monitorEMGval])
        set(app.MVCEditField, 'Value', round(app.monitorEMGval));

	end
	
	if app.monitorFlg
		if app.monitorEMGval >= app.goalMin && app.monitorEMGval <= app.goalMax		%% in the green
			set(app.hLine, 'Color', [40 224 47]/255);
            if app.inGreenFlag == true
                green_time_duration = toc(app.inGreenTstart);
                app.msgText.Text = ['t = ' num2str(green_time_duration,2)];
            else
                app.inGreenFlag = true;
                app.inGreenTstart = tic;
            end

		elseif app.monitorEMGval > app.goalMax && ...
				app.monitorEMGval <= (app.goalVal + 0.1*app.peakVal)		%% slightly above (purple)
			set(app.hLine, 'Color', [170 100 245]/255);
            app.inGreenFlag = false;
		elseif app.monitorEMGval > (app.goalVal + 0.1*app.peakVal)		%% far above goal (red)
			set(app.hLine, 'Color', [209 36 36]/255);
            app.inGreenFlag = false;
		elseif app.monitorEMGval > (app.goalVal - 0.1*app.peakVal) && ...	%% slightly below (orange)
			app.monitorEMGval <= (app.goalVal - 0.05*app.peakVal)
			set(app.hLine, 'Color', [255 193 59]/255)
            app.inGreenFlag = false;
		else
			set(app.hLine, 'Color', [239 245 71]/255)			%% far below goal (yellow)
            app.inGreenFlag = false;
		end
	end

return
