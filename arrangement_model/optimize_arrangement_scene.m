function [ final_scene, missed_obj, temp_scenes ] = optimize_arrangement_scene( input_scene, obj_id )
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
load(sidetoside_constraints_file_v2, 'sidetoside_constraints');
temp_scenes = [];
missed_obj = [];

parents = 1;
room = input_scene(1);
% new_objects = input_scene;
final_scene = room;
use_hard_constraints = 1;
init_locations = [0,0; .65,0; 0,.65; .65,.65; -.65,0; 0,-.65; -.65,-.65; -.65,.65; .65,-.65];

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
        
%     children = parent.children;
    children = structfind(input_scene, 'supporter_id', parent.identifier)';
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
    obj_rels_count = count_object_relations( input_scene, children );
    [rels_sorted, rels_ind] = sort(obj_rels_count, 'descend');
    children = children(rels_ind);
    
    % put the ones with previously optimized location on the top
    opt_locations = [input_scene(children).optimized_location];
    [opt_loc_sorted, opt_loc_ind] = sort(opt_locations, 'descend');
    
    for oid = 1:length(opt_loc_sorted)
        object = input_scene(children(opt_loc_ind(oid)));
        if object.optimized_location
            final_scene = [final_scene; object];
            sibling_list = [sibling_list; object];
            continue
        end
        
        fprintf('Start optimizing the placement for %s\n', object.identifier);
        
        repeat_sampling = 1;
        
        %update local_scene
        local_scene = parent;
        local_scene = update_local_scene(local_scene, final_scene, ...
            input_scene, children(opt_loc_ind(oid)), sidetoside_constraints);        
%         [ optimized_corners, optimized_orientation, final_cost ] = ...
%             optimize_arrangement_object( object, local_scene, final_scene, sibling_list, room, scene_counts );
        [all_xy, all_angle, all_score, all_pid, all_collision, all_sidetoside_constraints] = ...
            mcmc_optimize_arrangement_object( object, init_locations(1,:), local_scene, final_scene, sibling_list, 1000, use_hard_constraints );
        
        fprintf('Finished the first optimization!\n');
        
        if isempty(all_xy)
            global_corners_opt = object.corners;
            opt_orient = object.orientation;
        else
            [all_score_sorted, sort_ind] = sort(all_score);
            nonzero_ind = find(all_score_sorted);
            if isempty(nonzero_ind)
                top_ind = 1;
                repeat_sampling = 1;
            else
                index = 1;
                top_ind = nonzero_ind(index);
                if use_hard_constraints %if we didn't check for the constraints while sampling
                    while index < length(nonzero_ind) && (all_collision(sort_ind(top_ind)) ...
                            || ~all_sidetoside_constraints(sort_ind(top_ind)))
                        index = index + 1;
                        top_ind = nonzero_ind(index);
                    end
                    
                    %none of the samples satisfy the hard constraints
                    if index == length(nonzero_ind)
                        if all_collision(sort_ind(top_ind)) ...
                                || ~all_sidetoside_constraints(sort_ind(top_ind))
                            top_ind = 1;
                            repeat_sampling = 1;
                        else
                            repeat_sampling = 0;
                        end
                    else
                        repeat_sampling = 0;
                    end
                end
            end
            
            init_iter = 2;
            while repeat_sampling && init_iter <= length(init_locations)  %if a good sample is not found, re-start the sampling with another initial placement
                [all_xy, all_angle, all_score, all_pid, all_collision, all_sidetoside_constraints] = ...
                    mcmc_optimize_arrangement_object( object, init_locations(init_iter, :), ...
                    local_scene, final_scene, sibling_list, 1000, use_hard_constraints );
                init_iter = init_iter + 1;
                fprintf('finished iteration %d!\n', init_iter - 1);
                
                [all_score_sorted, sort_ind] = sort(all_score);
                nonzero_ind = find(all_score_sorted);
                if isempty(nonzero_ind)
                    top_ind = 1;
                    repeat_sampling = 1;
                else
                    index = 1;
                    top_ind = nonzero_ind(index);
                    if use_hard_constraints %if we didn't check for the constraints while sampling
                        while index < length(nonzero_ind) && (all_collision(sort_ind(top_ind)) ...
                                || ~all_sidetoside_constraints(sort_ind(top_ind)))
                            index = index + 1;
                            top_ind = nonzero_ind(index);
                        end
                        
                        %none of the samples satisfy the hard constraints
                        if index == length(nonzero_ind)
                            if all_collision(sort_ind(top_ind)) ...
                                    || ~all_sidetoside_constraints(sort_ind(top_ind))
                                top_ind = 1;
                                repeat_sampling = 1;
                            else
                                repeat_sampling = 0;
                            end
                        else
                            repeat_sampling = 0;
                        end
                    end
                end
            end
            
            %% to compare mcmc sampling with hill climbing in fisher's paper
%             if strcmp(object.identifier, obj_id)
%                 temp_scenes = struct('scene', []);
%                 step_size = fix(top_ind/4);
%                 step_size = max(10,step_size);
%                 samples_no = 6;
%                 
%                 for j = 1:step_size:top_ind-1
%                     top_xy = all_xy(sort_ind(j),:);
%                     top_angle = all_angle(sort_ind(j));
%                     top_pid = all_pid(sort_ind(j));
%                     %             top_pid = 1;
%                     
%                     object_dims = object.dims .* object.scale;
%                     pair = final_scene(top_pid);
%                     pair_dims = pair.dims .* pair.scale;
%                     z = mean(object.corners(:,3));
%                     top_xy = [top_xy(1) * (pair_dims(1)/2), top_xy(2) * (pair_dims(2)/2)];
%                     rel_center = [top_xy z];
%                     center = inv_convert_coordinates(-mean(pair.corners), pair.orientation, rel_center);
%                     
%                     %             theta = radtodeg(compute_theta_from_orientation(pair.orientation));
%                     %             opt_angle = theta + top_angle;
%                     opt_angle = smooth_final_angle(radtodeg(top_angle));
%                     opt_orient = [cos(degtorad(opt_angle)) sin(degtorad(opt_angle)) 0];
%                     
%                     opt_corners_bnd = [-object_dims/2 object_dims/2];
%                     local_corners = zeros(8,3);
%                     global_corners_opt = zeros(8,3);
%                     local_corners(1,:) = opt_corners_bnd(1:3);
%                     local_corners(2,:) = [opt_corners_bnd(4) opt_corners_bnd(2) opt_corners_bnd(3)];
%                     local_corners(3,:) = [opt_corners_bnd(4) opt_corners_bnd(5) opt_corners_bnd(3)];
%                     local_corners(4,:) = [opt_corners_bnd(1) opt_corners_bnd(5) opt_corners_bnd(3)];
%                     local_corners(5:8,:) = [local_corners(1:4,1:2), repmat(opt_corners_bnd(6), 4,1)];
%                     for i = 1:8
%                         global_corners_opt(i,:) = inv_convert_coordinates([-center(1:2) -z], opt_orient, local_corners(i,:));
%                     end
%                     
%                     object.corners = global_corners_opt;
%                     object.orientation = opt_orient;
%                     object.optimized_location = 1;
%                     temp_scenes(fix(j/step_size)+1,1).scene = [final_scene(1:end-1); object];
%                 end
                
%                 index = top_ind;
%                 while index <= length(sort_ind) && length(temp_scenes) < samples_no
%                     top_xy = all_xy(sort_ind(index),:);
%                     top_angle = all_angle(sort_ind(index));
%                     top_pid = all_pid(sort_ind(index));
%                     %             top_pid = 1;
%                     
%                     object_dims = object.dims .* object.scale;
%                     pair = final_scene(top_pid);
%                     pair_dims = pair.dims .* pair.scale;
%                     z = mean(object.corners(:,3));
%                     top_xy = [top_xy(1) * (pair_dims(1)/2), top_xy(2) * (pair_dims(2)/2)];
%                     rel_center = [top_xy z];
%                     center = inv_convert_coordinates(-mean(pair.corners), pair.orientation, rel_center);
%                     
%                     %             theta = radtodeg(compute_theta_from_orientation(pair.orientation));
%                     %             opt_angle = theta + top_angle;
%                     opt_angle = smooth_final_angle(radtodeg(top_angle));
%                     opt_orient = [cos(degtorad(opt_angle)) sin(degtorad(opt_angle)) 0];
%                     
%                     opt_corners_bnd = [-object_dims/2 object_dims/2];
%                     local_corners = zeros(8,3);
%                     global_corners_opt = zeros(8,3);
%                     local_corners(1,:) = opt_corners_bnd(1:3);
%                     local_corners(2,:) = [opt_corners_bnd(4) opt_corners_bnd(2) opt_corners_bnd(3)];
%                     local_corners(3,:) = [opt_corners_bnd(4) opt_corners_bnd(5) opt_corners_bnd(3)];
%                     local_corners(4,:) = [opt_corners_bnd(1) opt_corners_bnd(5) opt_corners_bnd(3)];
%                     local_corners(5:8,:) = [local_corners(1:4,1:2), repmat(opt_corners_bnd(6), 4,1)];
%                     for i = 1:8
%                         global_corners_opt(i,:) = inv_convert_coordinates([-center(1:2) -z], opt_orient, local_corners(i,:));
%                     end
%                     
%                     object.corners = global_corners_opt;
%                     object.orientation = opt_orient;
%                     object.optimized_location = 1;
%                     count = length(temp_scenes);
%                     temp_scenes(count+1,1).scene = [final_scene(1:end-1); object];
%                     index = index + step_size;
%                 end
%             end
            
%%
            %not a plausible arrangment
            if init_iter > length(init_locations)
                missed_obj = object;
                final_scene = [];
                return
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
            
%             theta = radtodeg(compute_theta_from_orientation(pair.orientation));
%             opt_angle = theta + top_angle;
            opt_angle = smooth_final_angle(radtodeg(top_angle));
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
        object.optimized_location = 1;
        final_scene = [final_scene; object];
        sibling_list = [sibling_list; object];
        
        fprintf('finished sampling for the placement of %s!\n', object.identifier);
        
%         local_scene = [local_scene; object];

        %debug
%         for i = 1:length(final_scene)
%             plot(final_scene(i).corners(1:5,1), final_scene(i).corners(1:5,2));
%             hold on
%         end
%         hold off
        
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

% obj_type = input_scene(obj_ind).obj_type;
% object_rows = [structfind(sidetoside_constraints, 'first_type', obj_type), ...
%     structfind(sidetoside_constraints, 'second_type', obj_type)];
% if ~isempty(object_rows)
%     constraints = sidetoside_constraints(object_rows);
%     
%     for oid = 1:length(final_scene)
%         pair_type = final_scene(oid).obj_type;
%         rows = [structfind(constraints, 'first_type', pair_type), ...
%             structfind(constraints, 'second_type', pair_type)];
%         if isempty(rows)
%             continue
%         end
%         for rid = 1:length(rows)
%             c = constraints(rows(rid));
%             if (c.first_side == 2 && c.second_side == 4) || ...
%                     (c.first_side == 4 && c.second_side == 2)
%                 if isempty(structfind(local_scene, 'identifier', final_scene(oid).identifier))
%                     local_scene = [local_scene; final_scene(oid)];
%                 end
%             end
%         end
%     end
% 
% end

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


