function [ scene3d ] = prepare_data_to_write_file( final_scene )
%PREPARE_DATA_TO_WRITE_FILE Summary of this function goes here
%   Detailed explanation goes here

objects_num = length(final_scene);
scene3d = repmat(struct('mindex',[], 'mid', [], 'pindex', [], ...
    'children', [], 'scale', [], 'transform', []), objects_num, 1);

for oid = 1:objects_num
    scene3d(oid).mindex = oid - 1;
    scene3d(oid).mid = final_scene(oid).modelname;
    
    % finding the parent
    if final_scene(oid).obj_type == get_object_type_bedroom({'room'})
        scene3d(oid).pindex = -1;
    else
%         parent_type = final_scene(oid).supporter_category;
%         support_row = structfind(nodes_with_support, 'obj_type', final_scene(oid).type);
%         parent_type = nodes_with_support(support_row(1)).supporter;
%         if parent_type > 54
%             parent_type = 29;
%         end
        parent_ind = structfind(final_scene, 'identifier', final_scene(oid).supporter_id);
        scene3d(oid).pindex = parent_ind(1) - 1;
    end
        
    scene3d(oid).scale = final_scene(oid).scale;
    if isempty(final_scene(oid).transform)
        scene3d(oid).transform = [1 0 0 0; 0 1 0 0; 0 0 1 0; 0 0 0 1];
    else
        scene3d(oid).transform = final_scene(oid).transform;
    end
    
    scene3d(oid).pmgindex = 0;
    scene3d(oid).ptindex = 0;
    scene3d(oid).parentuv = [0 0];
    scene3d(oid).pcontactposition = [0 0 0];
    scene3d(oid).pcontactnormal = [0 0 0];
    scene3d(oid).poffset = [0 0 0];
end

for oid = 1:objects_num
    children = [];
    rows = structfind(scene3d, 'pindex', oid-1);
    if isempty(rows)
        continue
    end
    children = rows - 1;
    scene3d(oid).children = children;
end

end

