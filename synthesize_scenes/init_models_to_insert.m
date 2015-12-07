function [ scene ] = init_models_to_insert( scene )
%INIT_MODELS_TO_INSERT initialize objects with placement and orientation to
%optimize arrangements

models_num = length(scene);
scene(1).children = [];
% new_objects = repmat(struct('type', [], 'type_name', [], 'modelname',[], 'scale',[],...
%     'corners', [], 'orientation', [], 'ptype', [], 'children', []), models_num, 1);

align_ind = [1 2 3; 4 2 3; 4 5 3; 1 5 3; 1 2 6; 4 2 6; 4 5 6; 1 5 6];

%assumption: room is always the first object in the scene
room = scene(1);
room_dims_scaled = room.dims * room.scale;
room_corners_bnd = [0 0 0 room_dims_scaled];
scene(1).corners = room_corners_bnd(align_ind);
scene(1).orientation = [1,0,0];
room_center = (min(scene(1).corners) + max(scene(1).corners)) / 2;

for mid = 2:models_num
    model = scene(mid);
    dims_scaled = model.dims * model.scale;
%     rand_bias = rand(1,2) .* (room_dims_scaled(1:2)/4); 
%     corners_bnd = [room_center(1:2) - dims_scaled(1:2)/2 + rand_bias, 0, ...
%         room_center(1:2) + dims_scaled(1:2)/2 + rand_bias, dims_scaled(3)];
    corners_bnd = [0 0 0 dims_scaled];
    scene(mid).corners = corners_bnd(align_ind);
        
    %support
%     supp_row = structfind(nodes_with_support, 'obj_type', model.obj_type);
%     supporter = nodes_with_support(supp_row(1)).supporter;
%     if supporter > 54
%         new_objects(mid).ptype = get_object_type_bedroom({'room'});
%     else
%         new_objects(mid).ptype = supporter;
%     end
    supporter_id = model.supporter_id;
    supporter_ind = structfind(scene, 'identifier', supporter_id);
    if ~isempty(supporter_ind)
        scene(supporter_ind).children = [scene(supporter_ind).children, mid];
    end
    
    if model.support_type == 3 %support from behind
        scene(mid).orientation = [1,0,0];
    else
%         orient = model.dims(1:2) ./ norm(model.dims(1:2));
        scene(mid).orientation = [0,1,0];
    end
    
%     new_objects(mid).type = model.obj_type;
%     new_objects(mid).type_name = get_object_type_bedroom(model.obj_type);
%     new_objects(mid).modelname = model.modelname;
%     new_objects(mid).scale = model.scale;
%     new_objects(mid).corners = corners_bnd(align_ind);
end

%correcting z coordinates, ignore the room
for mid = 2:models_num
    if isempty(scene(mid).children)
        continue
    end
    
    pcorners = scene(mid).corners;
    pheight = max(pcorners(:,3));
    children = scene(mid).children;
    for cid = 1:length(children)
        c = scene(children(cid)).corners;
        c(:,3) = c(:,3) + pheight;
        scene(children(cid)).corners = c;
    end
end

end

