function [ scene ] = init_models_to_insert( scene )
%INIT_MODELS_TO_INSERT initialize objects with placement and orientation to
%optimize arrangements

models_num = length(scene);
for i = 1:length(scene)
    scene(i).children = [];
end
% new_objects = repmat(struct('type', [], 'type_name', [], 'modelname',[], 'scale',[],...
%     'corners', [], 'orientation', [], 'ptype', [], 'children', []), models_num, 1);

align_ind = [1 2 3; 4 2 3; 4 5 3; 1 5 3; 1 2 6; 4 2 6; 4 5 6; 1 5 6];

%assumption: room is always the first object in the scene
room = scene(1);
room_dims_scaled = room.dims .* room.scale;
room_corners_bnd = [0 0 0 room_dims_scaled];
if isempty(room.corners)
    scene(1).corners = room_corners_bnd(align_ind);
    scene(1).orientation = [1,0,0];
end;
room_center = (min(scene(1).corners) + max(scene(1).corners)) / 2;

new_objs = zeros(1,models_num);
for mid = 2:models_num
    model = scene(mid);
    supporter_id = model.supporter_id;
    supporter_ind = structfind(scene, 'identifier', supporter_id);
    if ~isempty(supporter_ind)
        scene(supporter_ind).children = [scene(supporter_ind).children, mid];
    end
    
    if isfield(scene, 'corners') && ~isempty(model.corners)
        continue
    end
    
    new_objs(mid) = 1;
    dims_scaled = model.dims .* model.scale;
    corners_bnd = [0 0 0 dims_scaled];
    scene(mid).corners = corners_bnd(align_ind);
    
    if model.support_type == 3 %support from behind
        scene(mid).orientation = [1,0,0];
    else
%         orient = model.dims(1:2) ./ norm(model.dims(1:2));
        scene(mid).orientation = [0,1,0];
    end

end

%correcting z coordinates, ignore the room
for mid = 2:models_num
    children = structfind(scene, 'supporter_id', scene(mid).identifier);
    if isempty(children)
        continue
    end
    
    pcorners = scene(mid).corners;
    pheight = max(pcorners(:,3));
%     children = scene(mid).children;
    for cid = 1:length(children)
        if ~new_objs(children(cid))
            continue
        end
        c = scene(children(cid)).corners;
        c(:,3) = c(:,3) + pheight;
        scene(children(cid)).corners = c;
    end
end

end

