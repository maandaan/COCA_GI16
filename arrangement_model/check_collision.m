function [ collided ] = check_collision( newobj_placement, newobj_dims, scene )
%CHECK_COLLISION checks whether the new placement is colliding the
%placement of already placed objects.

newobj_center = newobj_placement(1:3);
newobj_BB = [newobj_center - newobj_dims/2; newobj_center + newobj_dims/2];

epsilon = 0.00001;
collided = false;
for oid = 1:length(scene)
    pair = scene(oid);
    pair_BB = [min(pair.corners); max(pair.corners)];
    
    if pair.obj_type == get_object_type_bedroom({'room'})
        continue
    end
    
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

