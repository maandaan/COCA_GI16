function collision_penalty = compute_collision_penalty( scene, obj, oid )
%COMPUTE_COLLISION_PENALTY checks whether the obj that we want to place in
%the scene collides with any other objects already placed.

epsilon = 0.00001;
collided = false;

%special case
if obj.obj_type == get_object_type_bedroom({'room'})
    collision_penalty = 1;
    return
end

obj_height = [min(obj.corners(:,3)), max(obj.corners(:,3))];
obj_rect = obj.corners(1:4,1:2);

for pid = 1:length(scene)
    if oid == pid || scene(pid).obj_type == get_object_type_bedroom({'room'})
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

