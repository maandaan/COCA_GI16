function overhang_penalty = compute_overhang_penalty( obj, parent )
%COMPUTE_OVERHANG_PENALTY computes the percentage of the projection of the
%bounding box of an object supported by its parent.

obj_w = norm(obj.corners(1,:) - obj.corners(2,:));
obj_l = norm(obj.corners(2,:) - obj.corners(3,:));
obj_area = obj_w * obj_l;

% parent_w = [min(parent.corners(1:4,1)), max(parent.corners(1:4,1))];
% parent_l = [min(parent.corners(1:4,2)), max(parent.corners(1:4,2))];
% 
% x_intersect = range_intersection(obj_w, parent_w);
% y_intersect = range_intersection(obj_l, parent_l);

% if isempty(x_intersect) || isempty(y_intersect)
%     overhang_penalty = 0;
%     return
% end
% 
% projected_area = (x_intersect(2) - x_intersect(1)) * (y_intersect(2) - y_intersect(1));

obj_rect_x = obj.corners(1:4,1)';
obj_rect_y = obj.corners(1:4,2)';
parent_rect_x = parent.corners(1:4,1)';
parent_rect_y = parent.corners(1:4,2)';

[x,y] = polybool('intersection',obj_rect_x, obj_rect_y, parent_rect_x, parent_rect_y);
projected_area = polyarea(x,y);

% overhang_penalty = (projected_area / obj_area) * 100;
overhang_penalty = projected_area / obj_area;

if overhang_penalty < .8
    overhang_penalty = 0;
% else
%     overhang_penalty = 0;
end

end

