function new_layout = generate_new_layout( scene )
%GENERATE_NEW_LAYOUT perturbs the object configurations for the process of
%optimizing the placement.

%assumption: the first object is the room itself
room = scene(1);
room_dims = room.dims .* room.scale;

new_layout = scene;
for oid = 1:length(scene)
    obj = scene(oid);
    if obj.obj_type == get_object_type_bedroom({'room'})
        continue
    end
    
    %perturbation in orientation
    angle = radtodeg(atan(obj.orientation(2) / obj.orientation(1)));
    if obj.orientation(1) < 0 %2nd and 3rd quarter
        angle = angle + 180;
    end
    delta_angle = normrnd(0, 20);
    if delta_angle > 180
        delta_angle = 180;
    end
    new_angle = delta_angle + angle;
    obj.orientation = [cos(degtorad(new_angle)), sin(degtorad(new_angle)), 0];
    
    
    %perturbation in placement
    obj_center = mean(obj.corners);
    obj_dims = obj.dims .* obj.scale;
    sigma = 0.2 .* obj_dims;
    new_center_x = obj_center(1) + normrnd(0, sigma(1));
    new_center_y = obj_center(2) + normrnd(0, sigma(2));
    new_center = [new_center_x new_center_y obj_center(3)];
    
%     min_x = new_center_x - obj_dims(1)/2;
%     max_x = new_center_x + obj_dims(1)/2;
%     
%     min_y = new_center_y - obj_dims(2)/2;
%     max_y = new_center_y + obj_dims(2)/2;
%     
%     obj.corners(:,1:2) = [min_x min_y; max_x min_y; max_x max_y; min_x max_y; ...
%         min_x min_y; max_x min_y; max_x max_y; min_x max_y];

    opt_corners_bnd = [-obj_dims/2 obj_dims/2];
    local_corners = zeros(8,3);
    global_corners = zeros(8,3);
    local_corners(1,:) = opt_corners_bnd(1:3);
    local_corners(2,:) = [opt_corners_bnd(4) opt_corners_bnd(2) opt_corners_bnd(3)];
    local_corners(3,:) = [opt_corners_bnd(4) opt_corners_bnd(5) opt_corners_bnd(3)];
    local_corners(4,:) = [opt_corners_bnd(1) opt_corners_bnd(5) opt_corners_bnd(3)];
    local_corners(5:8,:) = [local_corners(1:4,1:2), repmat(opt_corners_bnd(6), 4,1)];
    for i = 1:8
        global_corners(i,:) = inv_convert_coordinates(-new_center, obj.orientation, local_corners(i,:));
    end
    obj.corners = global_corners;
   
    new_layout(oid) = obj;
end

end

