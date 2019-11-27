function mep_auc_line_drag_endfcn(h_line)


% get min & max line x values
h_min_line = findobj(h_line.Parent, 'Tag', 'mep_min_line');
mep_start_time = h_min_line.XData(1);

h_max_line = findobj(h_line.Parent, 'Tag', 'mep_max_line');
mep_end_time = h_max_line.XData(1);

pre_stim_line = findobj(h_line.Parent, 'Tag', 'pre_stim_line');
pre_stim_val = pre_stim_line.YData(1);

hl = findobj(h_line.Parent, 'Tag', 'data_line');
h_patch = findobj(h_line.Parent, 'Tag', 'auc_patch');

update_auc_patch( mep_start_time, mep_end_time, hl, h_patch, pre_stim_val)

