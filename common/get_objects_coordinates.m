function [ scene3d ] = get_objects_coordinates( scene3d )
% This function is to compute the world coordinates for bounding boxes of
% objects in the scene based on their local coordinates and transform
% vector. (by Zeinab Sadeghipour)

% scene3d = read_scene_txt(scene_filename);
bb_file = 'data/bounding_boxes.mat';
load(bb_file, 'bounding_box');

for oid = 1:scene3d.modelcount
    object = scene3d.objects(oid);
    model_names = {bounding_box(:).name};
    bb_index = find(strcmp(model_names, object.mid));
    
    if isempty(bb_index)
        continue;
    end
    
    local_bb = bounding_box(bb_index).bb;
    object.local_bb = local_bb;
    transformed_coor_min = object.transform' * [local_bb(1,:) 1]';
    transformed_coor_max = object.transform' * [local_bb(2,:) 1]';
    object.world_bb = [transformed_coor_min(1:3)'; transformed_coor_max(1:3)'];
    
    scene3d.objects(oid) = object;
end

end

