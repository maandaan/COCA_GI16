function [ final_scene ] = optimize_arrangement_scene( input_scene )
%OPTIMIZE_ARRANGEMENT_SCENE optimizes the location for all the objects in
%the scene after we specified which objects should be placed.

% input_scene and new_objects should be lists of object categories along
% with their random initial corners and orientation, of course for
% input_scene it's not random and the placement is fixed. And also their
% supporting surfaces.

%count the number of bedroom instances with 3D ground truth
mapping_file = 'data/training/SUNRGBD/scene_name_type.mat';
scene_counts = count_annotated_scene_instances( 'bedroom', mapping_file );

parents = 1;
room = input_scene(1);
% new_objects = input_scene;
final_scene = room;

while length(final_scene) < length(input_scene)
    
    if parents == 0
        parent = room;
%         pindex = -1;
    else
        parent_input_scene = input_scene(parents(1)).identifier;
        pindex = structfind(final_scene, 'identifier', parent_input_scene);
        parent = final_scene(pindex);
    end
%     parent = input_scene(parents(1));
    parents = parents(2:end);
        
    children = parent.children;
    if isempty(children)
        continue
    end
    
    sibling_list = [];
        
    objects_vol = zeros(length(children),1);
    for oid = 1:length(children)
        obj = input_scene(children(oid));
        obj_dims = obj.dims .* obj.scale; %max(obj.corners) - min(obj.corners);
        objects_vol(oid) = prod(obj_dims);
    end
    [vol_sorted, ind] = sort(objects_vol, 'descend');
    
    children = children(ind);
    objects_relations = zeros(length(children),1);
    for oid = 1:length(children)
        obj = input_scene(children(oid));
        objects_relations(oid) = length(obj.symm_group_id) + ...
            ~isempty(obj.symm_ref_id) + length(obj.orientation_rels) ...
            - ~isempty(obj.symm_group_id);
    end
    [rels_sorted, rels_ind] = sort(objects_relations, 'descend');
    
    for oid = 1:length(rels_sorted)
        object = input_scene(children(rels_ind(oid)));
        %update local_scene
        local_scene = parent;
        local_scene = update_local_scene(local_scene, final_scene, input_scene, children(rels_ind(oid)));
        if length(final_scene) == 19
            fprintf('lets debug!\n');
        end
        [ optimized_corners, optimized_orientation, final_cost ] = ...
            optimize_arrangement_object( object, local_scene, final_scene, sibling_list, room, scene_counts );
        object.corners = optimized_corners;
        object.orientation = optimized_orientation;
        final_scene = [final_scene; object];
        sibling_list = [sibling_list; object];
%         local_scene = [local_scene; object];
    end
    
    parents = [parents, children];
end

end

function local_scene = update_local_scene(local_scene, final_scene, input_scene, obj_ind)
% Updates the local scene to include objects with symmetry and orientation
% relations

final_ids = {final_scene(:).identifier};
% input_ids = {};

%symmetry group
for sid = 1:length(input_scene(obj_ind).symm_group_id)
    symm_g = input_scene(obj_ind).symm_group_id;
    % the object itself
    if strcmp(symm_g{sid}, input_scene(obj_ind).identifier)
        continue
    end
    
    if ismember(symm_g{sid}, final_ids)
        pair_obj_ind = structfind(input_scene, 'identifier', symm_g{sid});
        if isempty(pair_obj_ind)
            continue
        end
        local_scene = [local_scene; input_scene(pair_obj_ind)];
    end
end

%symmetry reference
if ~isempty(input_scene(obj_ind).symm_ref_id) && ...
        ismember(input_scene(obj_ind).symm_ref_id, final_ids)
    
    pair_obj_ind = structfind(input_scene, 'identifier', input_scene(obj_ind).symm_ref_id);
    if ~isempty(pair_obj_ind)
        local_scene = [local_scene; input_scene(pair_obj_ind)];
    end
end

%orientation relations
for sid = 1:length(input_scene(obj_ind).orientation_rels)
    orientations = input_scene(obj_ind).orientation_rels;
        
    if ismember(orientations(sid).pair_obj_id, final_ids)
        pair_obj_ind = structfind(input_scene, 'identifier', orientations(sid).pair_obj_id);
        if isempty(pair_obj_ind)
            continue
        end
        local_scene = [local_scene; input_scene(pair_obj_ind)];
    end
end

end

