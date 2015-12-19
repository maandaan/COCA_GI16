function [ final_scene ] = optimize_arrangement_scene( input_scene )
%OPTIMIZE_ARRANGEMENT_SCENE optimizes the location for all the objects in
%the scene after we specified which objects should be placed.

% input_scene and new_objects should be lists of object categories along
% with their random initial corners and orientation, of course for
% input_scene it's not random and the placement is fixed. And also their
% supporting surfaces.

%count the number of bedroom instances with 3D ground truth
mapping_file = 'data/training/SUNRGBD/scene_name_type.mat';
% scene_counts = count_annotated_scene_instances( 'bedroom', mapping_file );

Consts;
load(sidetoside_constraints_file, 'sidetoside_constraints');

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
    parents = parents(2:end);
        
    children = parent.children;
    if isempty(children)
        continue
    end
    
    sibling_list = parent;
        
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
        fprintf('Start optimizing the placement for %s\n', object.identifier);
        
        %update local_scene
        local_scene = parent;
        local_scene = update_local_scene(local_scene, final_scene, ...
            input_scene, children(rels_ind(oid)), sidetoside_constraints);        
%         [ optimized_corners, optimized_orientation, final_cost ] = ...
%             optimize_arrangement_object( object, local_scene, final_scene, sibling_list, room, scene_counts );
        [all_xy, all_angle, all_score, all_pid] = ...
            mcmc_optimize_arrangement_object( object, local_scene, final_scene, sibling_list, 2000 );
        
        if isempty(all_xy)
            global_corners_opt = object.corners;
            opt_orient = object.orientation;
        else
            [all_score_sorted, sort_ind] = sort(all_score);
            nonzero_ind = find(all_score_sorted);
            if isempty(nonzero_ind)
                top_ind = 1;
            else
                top_ind = nonzero_ind(1);
            end
            top_xy = all_xy(sort_ind(top_ind),:);
            top_angle = all_angle(sort_ind(top_ind));
            top_pid = all_pid(sort_ind(top_ind));
%             top_pid = 1;
            
            object_dims = object.dims .* object.scale;
            pair = local_scene(top_pid);
            pair_dims = pair.dims .* pair.scale;
            z = mean(object.corners(:,3));
            top_xy = [top_xy(1) * (pair_dims(1)/2), top_xy(2) * (pair_dims(2)/2)];
            rel_center = [top_xy z];
            center = inv_convert_coordinates(-mean(pair.corners), pair.orientation, rel_center);
            
            theta = radtodeg(compute_theta_from_orientation(pair.orientation));
            opt_angle = theta + top_angle;
            opt_angle = smooth_final_angle(opt_angle);
            opt_orient = [cos(degtorad(opt_angle)) sin(degtorad(opt_angle)) 0];
            
            opt_corners_bnd = [-object_dims/2 object_dims/2];
            local_corners = zeros(8,3);
            global_corners_opt = zeros(8,3);
            local_corners(1,:) = opt_corners_bnd(1:3);
            local_corners(2,:) = [opt_corners_bnd(4) opt_corners_bnd(2) opt_corners_bnd(3)];
            local_corners(3,:) = [opt_corners_bnd(4) opt_corners_bnd(5) opt_corners_bnd(3)];
            local_corners(4,:) = [opt_corners_bnd(1) opt_corners_bnd(5) opt_corners_bnd(3)];
            local_corners(5:8,:) = [local_corners(1:4,1:2), repmat(opt_corners_bnd(6), 4,1)];
            for i = 1:8
                global_corners_opt(i,:) = inv_convert_coordinates([-center(1:2) -z], opt_orient, local_corners(i,:));
            end
        end
        
        object.corners = global_corners_opt;
        object.orientation = opt_orient;
        final_scene = [final_scene; object];
        sibling_list = [sibling_list; object];
%         local_scene = [local_scene; object];
    end
    
    parents = [parents, children];
end

end

function local_scene = update_local_scene(local_scene, final_scene, ...
    input_scene, obj_ind, sidetoside_constraints)
% Updates the local scene to include objects with symmetry and orientation
% relations

final_ids = {final_scene(:).identifier};
% input_ids = {};

obj_type = input_scene(obj_ind).obj_type;
object_rows = [structfind(sidetoside_constraints, 'first_type', obj_type), ...
    structfind(sidetoside_constraints, 'second_type', obj_type)];
if ~isempty(object_rows)
    constraints = sidetoside_constraints(object_rows);
    
    for oid = 1:length(final_scene)
        pair_type = final_scene(oid).obj_type;
        rows = [structfind(constraints, 'first_type', pair_type), ...
            structfind(constraints, 'second_type', pair_type)];
        if isempty(rows)
            continue
        end
        for rid = 1:length(rows)
            c = constraints(rows(rid));
            if (c.first_side == 2 && c.second_side == 4) || ...
                    (c.first_side == 4 && c.second_side == 2)
                if isempty(structfind(local_scene, 'identifier', final_scene(oid).identifier))
                    local_scene = [local_scene; final_scene(oid)];
                end
            end
        end
    end

end

%symmetry group
for sid = 1:length(input_scene(obj_ind).symm_group_id)
    symm_g = input_scene(obj_ind).symm_group_id;
    % the object itself
    if strcmp(symm_g{sid}, input_scene(obj_ind).identifier)
        continue
    end
    
    if ismember(symm_g{sid}, final_ids)
        pair_obj_ind = structfind(final_scene, 'identifier', symm_g{sid});
        if isempty(pair_obj_ind)
            continue
        end
        if isempty(structfind(local_scene, 'identifier', final_scene(pair_obj_ind).identifier))
            local_scene = [local_scene; final_scene(pair_obj_ind)];
        end
    end
end

%symmetry reference
if ~isempty(input_scene(obj_ind).symm_ref_id) && ...
        ismember(input_scene(obj_ind).symm_ref_id, final_ids)
    
    pair_obj_ind = structfind(final_scene, 'identifier', input_scene(obj_ind).symm_ref_id);
    if ~isempty(pair_obj_ind) && ...
       isempty(structfind(local_scene, 'identifier', final_scene(pair_obj_ind).identifier))
        local_scene = [local_scene; final_scene(pair_obj_ind)];
    end
end

%orientation relations
for sid = 1:length(input_scene(obj_ind).orientation_rels)
    orientations = input_scene(obj_ind).orientation_rels;
        
    if ismember(orientations(sid).pair_obj_id, final_ids)
        pair_obj_ind = structfind(final_scene, 'identifier', orientations(sid).pair_obj_id);
        if isempty(pair_obj_ind)
            continue
        end
        if isempty(structfind(local_scene, 'identifier', final_scene(pair_obj_ind).identifier))
            local_scene = [local_scene; final_scene(pair_obj_ind)];
        end
    end
end

end

function angle = smooth_final_angle(angle)

angle = mod(angle, 360);

if abs(angle - 0) <= 45 || abs(angle - 360) <= 45
    angle = 0;
% elseif abs(angle - 45) < 20
%     angle = 45;
elseif abs(angle - 90) < 45
    angle = 90;
% elseif abs(angle - 135) < 20
%     angle = 135;
elseif abs(angle - 180) <= 45
    angle = 180;
% elseif abs(angle - 225) < 20
%     angle = 225;
elseif abs(angle - 270) < 45
    angle = 270;
% elseif abs(angle - 315) < 20
%     angle = 315;
end

end


