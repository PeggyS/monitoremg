function update_auc_patch( mep_start_time, mep_end_time, hl, h_patch, pre_stim_val)

vertices = [];

mep_end_time_ind = find(hl.XData >= mep_end_time, 1, 'first');

above_stim_ind = find(hl.XData >= mep_start_time, 1, 'first');
abs_y = abs(hl.YData);

y_start = abs_y(above_stim_ind) - (abs_y(above_stim_ind)-abs_y(above_stim_ind-1))/(hl.XData(above_stim_ind)-hl.XData(above_stim_ind-1)) ...
	* (hl.XData(above_stim_ind) - mep_start_time);
if y_start >= pre_stim_val
	if abs_y(above_stim_ind) < pre_stim_val
		% emg is above threshold at mep start, but goes below threshold at
		% x_ind
		% add vertex at mep start and where it goes below threshold
		vertices = [vertices;
			mep_start_time pre_stim_val;
			mep_start_time y_start];
		% add the point where it crosses the pre stim line
		below_stim_ind = above_stim_ind;
		x_threshold = hl.XData(below_stim_ind) - (abs_y(below_stim_ind)-pre_stim_val)*(hl.XData(below_stim_ind)-hl.XData(below_stim_ind-1)) ...
			/ ( abs_y(below_stim_ind)-abs_y(below_stim_ind-1));
		vertices = [vertices;
			x_threshold pre_stim_val];
		
	else % abs_y(x_ind) > pre_stim_val % emg starting above pre stim
		% first vertex at mep start time
		vertices = [vertices;
			mep_start_time pre_stim_val;
			mep_start_time y_start];
	end
else % emg starts below pre stim
	% find where emg goes above prestim
	above_stim_ind = find(abs_y(above_stim_ind:end) > pre_stim_val, 1, 'first') + above_stim_ind-1;
	if isempty(above_stim_ind) || above_stim_ind > mep_end_time_ind
		% no data above threshold
		h_patch.Faces = 1:size(vertices,1);
		h_patch.Vertices = vertices;
		return
	end
	x_start = hl.XData(above_stim_ind) - (abs_y(above_stim_ind)-pre_stim_val)*(hl.XData(above_stim_ind)-hl.XData(above_stim_ind-1)) ...
		/ ( abs_y(above_stim_ind)-abs_y(above_stim_ind-1));
	vertices = [vertices;
		x_start pre_stim_val];
end
done = false;
while ~done
	% find next point where emg goes below pre_stim_val
	below_stim_ind = find(abs_y(above_stim_ind:end) <= pre_stim_val, 1, 'first') + above_stim_ind-1;
	
	if isempty(below_stim_ind) || below_stim_ind >= mep_end_time_ind
		% add points between above_stim_ind and mep_end_time_ind
		vertices = [vertices;
			hl.XData(above_stim_ind:mep_end_time_ind-1)' abs_y(above_stim_ind:mep_end_time_ind-1)'];
		% add vertex at mep_end_time
		y_end = abs_y(mep_end_time_ind) - (abs_y(mep_end_time_ind)-abs_y(mep_end_time_ind-1))/(hl.XData(mep_end_time_ind)-hl.XData(mep_end_time_ind-1)) ...
								* (hl.XData(mep_end_time_ind) - mep_end_time);
		if y_end > pre_stim_val
			vertices = [vertices;
						mep_end_time y_end;
						mep_end_time pre_stim_val];
		else
			if ~isempty(below_stim_ind)
				x_threshold = hl.XData(below_stim_ind) - (abs_y(below_stim_ind)-pre_stim_val)*(hl.XData(below_stim_ind)-hl.XData(below_stim_ind-1)) ...
					/ ( abs_y(below_stim_ind)-abs_y(below_stim_ind-1));
				vertices = [vertices;
					x_threshold pre_stim_val];
			end
		end
		% done defining vertices
		done = true;
	else
		% add points between above_stim_ind and below_stim_ind-1
		vertices = [vertices;
			hl.XData(above_stim_ind:below_stim_ind-1)' abs_y(above_stim_ind:below_stim_ind-1)'];
		% add the point where it crosses the pre stim line
		x_threshold = hl.XData(below_stim_ind) - (abs_y(below_stim_ind)-pre_stim_val)*(hl.XData(below_stim_ind)-hl.XData(below_stim_ind-1)) ...
			/ ( abs_y(below_stim_ind)-abs_y(below_stim_ind-1));
		vertices = [vertices;
			x_threshold pre_stim_val];
	end
	
	% find next point where emg goes above pre_stim_val
	above_stim_ind = find(abs_y(below_stim_ind:end) > pre_stim_val, 1, 'first') + below_stim_ind-1;
	if ~isempty(above_stim_ind)
		x_threshold = hl.XData(above_stim_ind) - (abs_y(above_stim_ind)-pre_stim_val)*(hl.XData(above_stim_ind)-hl.XData(above_stim_ind-1)) ...
			/ ( abs_y(above_stim_ind)-abs_y(above_stim_ind-1));

		if above_stim_ind >= mep_end_time_ind && x_threshold > mep_end_time
			% add vertex at mep_end_time
	% 		y_end = abs_y(mep_end_time_ind) - (abs_y(mep_end_time_ind)-abs_y(mep_end_time_ind-1))/(hl.XData(mep_end_time_ind)-hl.XData(mep_end_time_ind-1)) ...
	% 								* (hl.XData(mep_end_time_ind) - mep_end_time);
	% 		vertices = [vertices;
	% 					mep_end_time y_end;
	% 					mep_end_time pre_stim_val];
			% done defining vertices
			done = true;
		else
			% add vertex where emg gets to threshold
			vertices = [vertices;
						x_threshold pre_stim_val];
			if above_stim_ind == mep_end_time_ind
				y_end = abs_y(mep_end_time_ind) - (abs_y(mep_end_time_ind)-abs_y(mep_end_time_ind-1))/(hl.XData(mep_end_time_ind)-hl.XData(mep_end_time_ind-1)) ...
									* (hl.XData(mep_end_time_ind) - mep_end_time);
				vertices = [vertices;
							mep_end_time y_end;
							mep_end_time pre_stim_val];
			end
		end
	end
	
end % while not done adding vertices

% update the patch
h_patch.Vertices = vertices;
h_patch.Faces = 1:size(vertices,1);

auc = compute_auc(h_patch.Vertices)