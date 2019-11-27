
figure
x = 1:10;
y = sin(4*x);
hl = plot(x, y);
hl.Tag = 'data_line';
h_abs_l = line(x,abs(y),'Color',[0 0 0]);
pre_stim_val = 0.5;
line([1 10], [pre_stim_val pre_stim_val], 'color', [1 0 0], 'Tag', 'pre_stim_line')

h_t_min_line = line([3.5 3.5], [-1 1], 'Color', [0 1 0], 'Tag', 'mep_min_line');
draggable(h_t_min_line, 'h', 'endfcn', @mep_auc_line_drag_endfcn2)
h_t_max_line = line([8.5 8.5], [-1 1], 'Color', [0 1 0], 'Tag', 'mep_max_line');
draggable(h_t_max_line, 'h', 'endfcn', @mep_auc_line_drag_endfcn2)

h_patch = patch('Faces', [], 'Vertices', [], ...
	'FaceColor', [0.5 0.5 0.5], 'FaceAlpha', 0.5, 'Tag', 'auc_patch');

mep_start_time = h_t_min_line.XData(1);
mep_end_time = h_t_max_line.XData(1);

