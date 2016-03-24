function collision_penalty = compute_collision_penalty( scene, obj, oid )
%COMPUTE_COLLISION_PENALTY checks whether the obj that we want to place in
%the scene collides with any other objects already placed.

thresh = 5;
epsilon = 0.00001;
collided = false;

%special case
if strcmp(obj.obj_category, 'room')
    collision_penalty = 1;
    return
end

obj_height = [min(obj.corners(:,3)), max(obj.corners(:,3))];
%reducing the size a little bit to prevent discarding cases of negligible
%collision
obj_center = mean(obj.corners);
obj_dims = obj.dims .* obj.scale;
obj_dims(1:2) = obj_dims(1:2) - thresh;
corners_bnd = [-obj_dims/2 obj_dims/2];
local_corners = zeros(8,3);
newobj_corners = zeros(8,3);
local_corners(1,:) = corners_bnd(1:3);
local_corners(2,:) = [corners_bnd(4) corners_bnd(2) corners_bnd(3)];
local_corners(3,:) = [corners_bnd(4) corners_bnd(5) corners_bnd(3)];
local_corners(4,:) = [corners_bnd(1) corners_bnd(5) corners_bnd(3)];
local_corners(5:8,:) = [local_corners(1:4,1:2), repmat(corners_bnd(6), 4,1)];
for i = 1:8
    newobj_corners(i,:) = inv_convert_coordinates(-obj_center, obj.orientation, local_corners(i,:));
end
obj_rect = newobj_corners(1:4,1:2);

for pid = 1:length(scene)
    if oid == pid || strcmp(scene(pid).obj_category, 'room')
        continue
    end
    
    pair = scene(pid);
    pair_height = [min(pair.corners(:,3)), max(pair.corners(:,3))];
    pair_rect = pair.corners(1:4,1:2);
    z_intersect = range_intersection(obj_height, pair_height);
    xy_intersect = RectIntersect(pair_rect, obj_rect);
    
    collided = xy_intersect && ~isempty(z_intersect) && ...
        abs(z_intersect(1) - z_intersect(2)) > epsilon;
    
    if collided
        break
    end
end

collision_penalty = ~collided;

end

