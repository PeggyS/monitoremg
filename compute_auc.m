function auc = compute_auc(vertices)
% col 1 = x (assume that x values are in order from lowest to highest)
% col 2 = y (min y = flat base of shapes under the curve)

auc = 0;
if isempty(vertices)
	return
end

% the min y value vertex is the base of all the triangles, rectangles, etc
y_min = min(vertices(:,2));

% Start at 1st vertex, look at 2 consecutive vertices and determine the
% area under the triangle (if a vertex is at the base/min) or the triangle
% plus rectangle below it.
v_num_start = 1;

% vertex 1 & 2 have the same x value
if abs(vertices(1,1)-vertices(2,1)) < eps
	v_num_start = 2;
end

% go through each vertex 
for v_cnt = v_num_start+1:size(vertices,1)
	% shape is defined by vertex # v_cnt & v_cnt-1 & y_min
	
	% of one of the vertices is at y_min, then it's a triangle, otherwise
	% it's a triangle on top of a rectangle
	if abs(vertices(v_cnt,2)-y_min) < eps || abs(vertices(v_cnt-1,2)-y_min) < eps
		% triangle
		height = abs(vertices(v_cnt,2)-vertices(v_cnt-1,2));
		width = vertices(v_cnt,1)-vertices(v_cnt-1,1);
		auc = auc + height * width / 2;
	else
		% triangle on top of rectangle
		tri_height = abs(vertices(v_cnt,2)-vertices(v_cnt-1,2));
		width = vertices(v_cnt,1)-vertices(v_cnt-1,1);
		% add triangle
		auc = auc + tri_height * width / 2;
		% rectangle
		rect_height = min([vertices(v_cnt,2), vertices(v_cnt-1,2)]) - y_min;
		% add rectangle
		auc = auc + rect_height * width;
	end
end