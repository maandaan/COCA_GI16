function [new_obj, scores, max_score] = generate_initial_samples( scene, obj, parent, no_samples, gmm_matrix )
%GENERATE_INITIAL_SAMPLES Summary of this function goes here
%   Detailed explanation goes here

gmm = gmm_matrix(parent.obj_type, obj.obj_type).gmm;
samples = random(gmm, no_samples);

scores = zeros(no_samples,1);
sample_corners = repmat(struct('corners', []), no_samples, 1);
sample_orientations = repmat(struct('orientation', []), no_samples, 1);
for sid = 1:no_samples
    
    object_dims = obj.dims .* obj.scale;
    pair = parent;
    pair_dims = pair.dims .* pair.scale;
    z = mean(obj.corners(:,3));
    sample_xy = [samples(sid,1) * (pair_dims(1)/2), samples(sid,2) * (pair_dims(2)/2)];
    rel_center = [sample_xy z];
    center = inv_convert_coordinates(-mean(pair.corners), pair.orientation, rel_center);
    
    %             theta = radtodeg(compute_theta_from_orientation(pair.orientation));
    %             opt_angle = theta + top_angle;
%     opt_angle = smooth_final_angle(radtodeg(top_angle));
    sample_angle = samples(sid,4);
    
    theta = compute_theta_from_orientation(pair.orientation);
    angle1 = theta + degtorad(sample_angle);
    angle2 = theta - degtorad(sample_angle);
    object_orient1 = [cos(angle1) sin(angle1) 0];
    object_orient2 = [cos(angle2) sin(angle2) 0];
%     sample_orient = [cos(degtorad(sample_angle)) sin(degtorad(sample_angle)) 0];
    
    opt_corners_bnd = [-object_dims/2 object_dims/2];
    local_corners = zeros(8,3);
    global_corners_opt_1 = zeros(8,3);
    global_corners_opt_2 = zeros(8,3);
    local_corners(1,:) = opt_corners_bnd(1:3);
    local_corners(2,:) = [opt_corners_bnd(4) opt_corners_bnd(2) opt_corners_bnd(3)];
    local_corners(3,:) = [opt_corners_bnd(4) opt_corners_bnd(5) opt_corners_bnd(3)];
    local_corners(4,:) = [opt_corners_bnd(1) opt_corners_bnd(5) opt_corners_bnd(3)];
    local_corners(5:8,:) = [local_corners(1:4,1:2), repmat(opt_corners_bnd(6), 4,1)];
    for i = 1:8
        global_corners_opt_1(i,:) = inv_convert_coordinates([-center(1:2) -z], object_orient1, local_corners(i,:));
        global_corners_opt_2(i,:) = inv_convert_coordinates([-center(1:2) -z], object_orient2, local_corners(i,:));
    end
    
    obj.corners = global_corners_opt_1;
    obj.orientation = object_orient1;
    scene = [scene; obj];
    [~, sample_score_1] = compute_layout_score( scene, length(scene) );
    
    obj.corners = global_corners_opt_2;
    obj.orientation = object_orient2;
    scene = [scene(1:end-1); obj];
    [~, sample_score_2] = compute_layout_score( scene, length(scene) );
    
    if sample_score_1 > sample_score_2
        scores(sid) = sample_score_1;
        sample_corners(sid).corners = global_corners_opt_1;
        sample_orientations(sid).orientation = object_orient1;
    else
        scores(sid) = sample_score_2;
        sample_corners(sid).corners = global_corners_opt_2;
        sample_orientations(sid).orientation = object_orient2;
    end
    
    if mod(sid,50) == 0
        fprintf('it''s going on... iteration %d\n', sid);
    end
end

[scores_sorted, ind] = sort(scores, 'descend');
obj.corners = sample_corners(ind(1)).corners;
obj.orientation = sample_orientations(ind(1)).orientation;
max_score = scores(ind(1));
new_obj = obj;

end

