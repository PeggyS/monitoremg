function update_auc_patch2( mep_start_time, mep_end_time, hl, h_patch, pre_stim_val)

abs_y = abs(hl.YData);

% data in between the mep lines
mep_segment_msk = hl.XData >= mep_start_time & hl.XData <= mep_end_time;
% data below threshold in the segment
emg_below_threshold_msk = abs_y < pre_stim_val & mep_segment_msk;

% set data below threshold in the segment to pre_stim_val
vertices_y = abs_y;
vertices_y(emg_below_threshold_msk) = pre_stim_val;

% only use vertices in the mep_segment
vertices_y = vertices_y(mep_segment_msk);
vertices_x = hl.XData(mep_segment_msk);


% update the patch
h_patch.Vertices = [vertices_x(1) pre_stim_val;
					vertices_x' vertices_y'
					vertices_x(end) pre_stim_val];
h_patch.Faces = 1:size(h_patch.Vertices,1);

auc_trapz = trapz(vertices_y-pre_stim_val)
auc = compute_auc(h_patch.Vertices)