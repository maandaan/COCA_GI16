function new_layout = generate_new_layout( scene )
%GENERATE_NEW_LAYOUT perturbs the object configurations for the process of
%optimizing the placement.

%assumption: the first object is the room itself
% room = scene(1);
% room_dims = room.dims .* room.scale;

new_layout = scene;
%randomly choose one object to pertubate based on their sizes, bigger ->
%more probable to be selected
objects_vol = zeros(length(scene)-1,1);
for oid = 2:length(scene)
    obj = scene(oid);
    obj_dims = obj.dims .* obj.scale; %max(obj.corners) - min(obj.corners);
    objects_vol(oid-1) = prod(obj_dims);
end
% [vol_sorted, ind] = sort(objects_vol, 'descend');

r = rand;
prob = objects_vol ./ sum(objects_vol);
selected_obj_ind = sum(r >= cumsum([0, prob'])) + 1;
    
% selected_obj_ind = randi(length(scene)-1) + 1;
% for oid = 1:length(scene)
obj = scene(selected_obj_ind);
parent_row = structfind(scene, 'identifier', obj.supporter_id);
parent = scene(parent_row);
parent_dims = parent.dims .* parent.scale;
%     if obj.obj_type == get_object_type_bedroom({'room'})
%         continue
%     end

%perturbation in orientation
angle = radtodeg(atan(obj.orientation(2) / obj.orientation(1)));
if obj.orientation(1) < 0 %2nd and 3rd quarter
    angle = angle + 180;
end
delta_angle = normrnd(0, 45);
if delta_angle > 180
    delta_angle = 180;
end
new_angle = delta_angle + angle;
obj.orientation = [cos(degtorad(new_angle)), sin(degtorad(new_angle)), 0];


%perturbation in placement
obj_center = mean(obj.corners);
obj_dims = obj.dims .* obj.scale;
sigma = obj_dims ./ 5;
delta_x = normrnd(0, sigma(1));
delta_y = normrnd(0, sigma(2));

new_center_x = obj_center(1) + delta_x;
new_center_y = obj_center(2) + delta_y;
new_center = [new_center_x new_center_y obj_center(3)];

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

new_layout(selected_obj_ind) = obj;
% end

%it the object itself is the parent to a set of objects, the children
%should move as well
if ~isempty(obj.children)
    child_rows = structfind(new_layout, 'supporter_id', obj.identifier);
    for oid = 1:length(child_rows)
        obj = new_layout(child_rows(oid));
      
        angle = radtodeg(atan(obj.orientation(2) / obj.orientation(1)));
        new_angle = delta_angle + angle;
        obj.orientation = [cos(degtorad(new_angle)), sin(degtorad(new_angle)), 0];
        
        obj_center = mean(obj.corners);
        obj_dims = obj.dims .* obj.scale;
        new_center_x = obj_center(1) + delta_x;
        new_center_y = obj_center(2) + delta_y;
        new_center = [new_center_x new_center_y obj_center(3)];
        
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
        
        new_layout(child_rows(oid)) = obj;
    end
end

end

