function [ collided ] = check_collision( newobj_placement, newobj_dims, newobj_orient, scene )
%CHECK_COLLISION checks whether the new placement is colliding the
%placement of already placed objects.

newobj_center = newobj_placement(1:3);
% newobj_BB = [newobj_center - newobj_dims/2; newobj_center + newobj_dims/2];
corners_bnd = [-newobj_dims/2 newobj_dims/2];
local_corners = zeros(8,3);
newobj_corners = zeros(8,3);
local_corners(1,:) = corners_bnd(1:3);
local_corners(2,:) = [corners_bnd(4) corners_bnd(2) corners_bnd(3)];
local_corners(3,:) = [corners_bnd(4) corners_bnd(5) corners_bnd(3)];
local_corners(4,:) = [corners_bnd(1) corners_bnd(5) corners_bnd(3)];
local_corners(5:8,:) = [local_corners(1:4,1:2), repmat(corners_bnd(6), 4,1)];
for i = 1:8
    newobj_corners(i,:) = inv_convert_coordinates(-newobj_center, newobj_orient, local_corners(i,:));
end
% newobj_BB = [min(newobj_corners); max(newobj_corners)];

epsilon = 0.00001;
collided = false;
for oid = 1:length(scene)
    pair = scene(oid);
%     pair_BB = [min(pair.corners); max(pair.corners)];
    
    if pair.obj_type == get_object_type_bedroom({'room'})
        continue
    end
    
    rel_pair_corners = zeros(8,3);
    cos_t = newobj_orient(2) / norm(newobj_orient);
    sin_t = -newobj_orient(1) / norm(newobj_orient);
    for i = 1:8
        rel_pair_corners(i,:) = convert_coordinates(newobj_center, cos_t, sin_t, pair.corners(i,:));
    end
    pair_BB = [min(rel_pair_corners); max(rel_pair_corners)];
    newobj_BB = [corners_bnd(1:3); corners_bnd(4:6)];
    
    %if in all 3 dimensions, two objects have intersection, it means
    %they're colliding
    x_intersect = range_intersection(newobj_BB(:,1), pair_BB(:,1));
    y_intersect = range_intersection(newobj_BB(:,2), pair_BB(:,2));
    z_intersect = range_intersection(newobj_BB(:,3), pair_BB(:,3));
    
    collided = ~isempty(x_intersect) && ~isempty(y_intersect) && ~isempty(z_intersect) && ...
        abs(x_intersect(1) - x_intersect(2)) > epsilon && abs(y_intersect(1) - y_intersect(2)) > epsilon ...
        && abs(z_intersect(1) - z_intersect(2)) > epsilon;
    if collided
        break
    end
end

end

