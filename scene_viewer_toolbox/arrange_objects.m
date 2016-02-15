function [arranged_scenes, scores] = arrange_objects( input_scene, step_size )
%ARRANGE_OBJECTS optimizes the placement of objects based on the
%arrangement model in the example-based scene synthesis paper (Fisher et
%al.)

Consts_fisher;
load(gmm_location_file_SUNRGBD, 'gmm_matrix');

scene = input_scene;
max_iter = 500;

scores = zeros(step_size, 1);
arranged_scenes = repmat(struct('scene',[]), step_size, 1);

%% sorting based on the sizes
objects_vol = zeros(length(scene),1);
for oid = 1:length(scene)
    obj = scene(oid);
    obj_dims = obj.dims .* obj.scale; %max(obj.corners) - min(obj.corners);
    objects_vol(oid) = prod(obj_dims);
end
[~, ind] = sort(objects_vol, 'descend');
scene = scene(ind);

%% initializing the placement
for oid = 2:length(scene)
    obj = scene(oid);
    obj_dims = obj.dims .* obj.scale;
    parent_row = structfind(scene, 'identifier', obj.supporter_id);
    parent = scene(parent_row);
    parent_bnd = [min(parent.corners(:,1)), max(parent.corners(:,1)); ...
        min(parent.corners(:,2)), max(parent.corners(:,2)); ...
        min(parent.corners(:,3)), max(parent.corners(:,3))];
    
    %initializing z
    if parent.obj_type == get_object_type_bedroom({'room'})
        min_z = parent_bnd(3,1);
    else
        min_z = parent_bnd(3,2);
    end
    obj.corners(:,3) = [repmat(min_z,4,1); repmat(min_z + obj_dims(3),4,1)];
    
    score = 0;
    iter = 1;
    rng('shuffle')
    obj.orientation = [0,1,0];
%     while score == 0 && iter <= max_iter
%         center_x = parent_bnd(1,1) + (parent_bnd(1,2)-parent_bnd(1,1)) * rand;
%         center_y = parent_bnd(2,1) + (parent_bnd(2,2)-parent_bnd(2,1)) * rand;
%         
%         min_x = center_x - obj_dims(1)/2;
%         max_x = center_x + obj_dims(1)/2;
%         
%         min_y = center_y - obj_dims(2)/2;
%         max_y = center_y + obj_dims(2)/2;
%         
%         obj.corners(:,1:2) = [min_x min_y; max_x min_y; max_x max_y; min_x max_y; ...
%                               min_x min_y; max_x min_y; max_x max_y; min_x max_y];
%         
%         scene(oid) = obj;
%         [~, score] = compute_layout_score( scene(1:oid), oid );
%         iter = iter + 1;
%     end
%     if iter > max_iter
%         fprintf('Object %s cannot be placed!\n', obj.identifier);
%     else
%         fprintf('initialized object %s! :D \n', obj.identifier);
%     end
    [new_obj, temp_scores, max_score] = generate_initial_samples( scene(1:oid-1), obj, parent, max_iter, gmm_matrix );
    scene(oid) = new_obj;
end

%% optimizing the placement
optimization_maxiter = 100;
% scene = generate_new_layout(scene);
[score,~] = compute_layout_score(scene, 0);
step_count = 1;
for iter = 1:optimization_maxiter
    new_layout = generate_new_layout( scene );
    [new_score, ~] = compute_layout_score(new_layout,0);
    if mod(iter,step_size) == 0
        scores(step_count) = new_score;
        arranged_scenes(step_count).scene = new_layout;
        step_count = step_count + 1;
    end
    if new_score > score
        score = new_score;
        scene = new_layout;
    end
    fprintf('iteration %d finished! score: %f, new_score: %f\n', iter, score, new_score);
end

% arranged_scenes = scene;

end

