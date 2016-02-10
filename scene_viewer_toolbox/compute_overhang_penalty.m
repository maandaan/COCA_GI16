function overhang_penalty = compute_overhang_penalty( obj, parent )
%COMPUTE_OVERHANG_PENALTY computes the percentage of the projection of the
%bounding box of an object supported by its parent.

obj_w = [min(obj.corners(1:4,1)), max(obj.corners(1:4,1))];
obj_l = [min(obj.corners(1:4,2)), max(obj.corners(1:4,2))];
obj_area = (obj_w(2) - obj_w(1)) * (obj_l(2) - obj_l(1));

parent_w = [min(parent.corners(1:4,1)), max(parent.corners(1:4,1))];
parent_l = [min(parent.corners(1:4,2)), max(parent.corners(1:4,2))];

x_intersect = range_intersection(obj_w, parent_w);
y_intersect = range_intersection(obj_l, parent_l);

if isempty(x_intersect) || isempty(y_intersect)
    overhang_penalty = 0;
    return
end

projected_area = (x_intersect(2) - x_intersect(1)) * (y_intersect(2) - y_intersect(1));
overhang_penalty = (projected_area / obj_area) * 100;

end

