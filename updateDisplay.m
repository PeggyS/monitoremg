function updateDisplay(app, dataVec, markInfo)
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
	val = mean(abs(dataVec - mean(dataVec)));
%     disp(val)

	set(app.hLine, 'YData', [0 val]);
	if ~isempty(markInfo)
		% fid = fopen('magstim_val.txt', 'r');
		% magstim_val = fscanf(fid, '%d');
		% fclose(fid);
		magstim_val = app.magstim_mmap.Data(1);
        if strcmp(markInfo(1).label, ' ')
            % msg = sprintf('Msg: %s, y = %3.1f, ms = %d', markInfo(1).desc, val, magstim_val);
        else
            % msg = sprintf('Msg: %s, y = %3.1f, ms = %d', markInfo(1).label, val, magstim_val);
            msg = sprintf('emg = %4.0f, magstim = %d', val, magstim_val);
            drawnow
        end
		app.msgText.Text = msg;

		app.hStarMark.Position = [0.3, val];
	end

	if app.peakTracker
        % save val for sizeof(peakValVec) blocks of data
        
        app.peakValVec = circshift(app.peakValVec, [2 1]); % move all elements down
        app.peakValVec(1) = val;                        % put new val at beginning
        app.peakVal = mean(app.peakValVec);

        if app.peakVal > app.UIAxes.YLim(2)
        	set(app.UIAxes, 'YLim', [ 0, app.peakVal * 1.1]);
        	drawnow
        end

        set(app.hPeakLine, 'Visible', 'on')
 		if std(app.peakValVec) < 50        % arbitrary threshold
			%set(handles.peakPatch, 'YData', [peakVal-5 peakVal-5 peakVal peakVal])
			set(app.hPeakLine, 'Color', 'g');
            
        else 
            set(app.hPeakLine, 'Color', 'r');
        end
        set(app.hPeakLine, 'YData', [val val])
        set(app.MVCEditField, 'Value', round(val));

	end
	
	if app.monitorFlg
		if val >= (app.params.goalPct*app.peakVal - 0.05*app.peakVal) && ...
			val <= (app.params.goalPct*app.peakVal + 0.05*app.peakVal)		%% in the green
			set(app.hLine, 'Color', [40 224 47]/255);
		elseif val > (app.params.goalPct*app.peakVal + 0.05*app.peakVal) && ...
				val <= (app.params.goalPct*app.peakVal + 0.1*app.peakVal)		%% slightly above (purple)
			set(app.hLine, 'Color', [170 100 245]/255);
		elseif val > (app.params.goalPct*app.peakVal + 0.1*app.peakVal)		%% far above goal (red)
			set(app.hLine, 'Color', [209 36 36]/255);
		elseif val > (app.params.goalPct*app.peakVal - 0.1*app.peakVal) && ...	%% slightly below (orange)
			val <= (app.params.goalPct*app.peakVal - 0.05*app.peakVal)
			set(app.hLine, 'Color', [255 193 59]/255)
		else
			set(app.hLine, 'Color', [239 245 71]/255)			%% far below goal (yellow)
		end
	end

return
