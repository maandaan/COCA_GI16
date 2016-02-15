function new_layout = generate_new_layout( scene )
%GENERATE_NEW_LAYOUT perturbs the object configurations for the process of
%optimizing the placement.

new_layout = scene;
for oid = 1:length(scene)
    obj = scene(oid);
    if obj.obj_type == get_object_type_bedroom({'room'})
        continue
    end
    
    obj_center = mean(obj.corners);
    obj_dims = obj.dims .* obj.scale;
    sigma = 0.05 .* obj_dims;
    new_center_x = obj_center(1) + normrnd(0, sigma(1));
    new_center_y = obj_center(2) + normrnd(0, sigma(2));
    
    min_x = new_center_x - obj_dims(1)/2;
    max_x = new_center_x + obj_dims(1)/2;
    
    min_y = new_center_y - obj_dims(2)/2;
    max_y = new_center_y + obj_dims(2)/2;
    
    obj.corners(:,1:2) = [min_x min_y; max_x min_y; max_x max_y; min_x max_y; ...
        min_x min_y; max_x min_y; max_x max_y; min_x max_y];
    
    angle = radtodeg(atan(obj.orientation(2) / obj.orientation(1)));
    if obj.orientation(2) < 0 %2nd and 3rd quarter
        angle = angle + 180;
    end
    delta_angle = normrnd(0, 10);
    if delta_angle > 180
        delta_angle = 180;
    end
    new_angle = delta_angle + angle;
    obj.orientation = [cos(degtorad(new_angle)), sin(degtorad(new_angle)), 0];
    
    new_layout(oid) = obj;
end

end

